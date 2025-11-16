<?php

namespace App\Http\Controllers;

use App\Models\Conversacion;
use App\Models\Mensaje;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Services\BotService;
use App\Support\EmisorHelper;

class ChatController extends Controller
{
    public function __construct(private BotService $bot) {}

    public function chat(Request $request)
    {
        $data = $request->validate([
            'userId'         => 'required|integer',
            'message'        => 'required|string',
            'history'        => 'array',
            'conversationId' => 'nullable|integer'
        ]);

        $userId         = (int)$data['userId'];
        $userText       = trim($data['message']);
        $conversationId = $data['conversationId'] ?? null;

        // Conversación (por ahora mantenemos el 1001 fijo si no viene id)
        $conv = $conversationId
            ? Conversacion::find($conversationId)
            : Conversacion::firstOrCreate(
                ['id_conversacion' => 1001],
                ['id_usuario' => $userId, 'estado' => 'activa']
            );

        // === INSERT mensaje del usuario, robusto al ENUM ===
        $userEmisor = EmisorHelper::valueFor('user');
        try {
            $userMsg = Mensaje::create([
                'id_conversacion' => $conv->id_conversacion,
                'emisor'          => $userEmisor,
                'contenido'       => $userText,
                'fecha_envio'     => now(),
                'id_faq'          => null,
                'id_recurso'      => null,
            ]);
        } catch (\Throwable $e) {
            Log::error('Insert MENSAJES (usuario) falló: '.$e->getMessage(), [
                'enum' => EmisorHelper::enumValues(),
                'intent' => $userEmisor
            ]);
            // Segundo intento: usar primera opción del enum explícitamente
            $fallback = EmisorHelper::enumValues()[0] ?? null;
            $userMsg = Mensaje::create([
                'id_conversacion' => $conv->id_conversacion,
                'emisor'          => $fallback,
                'contenido'       => $userText,
                'fecha_envio'     => now(),
                'id_faq'          => null,
                'id_recurso'      => null,
            ]);
        }

        // === Búsqueda simple en tablas, SIN scores (pero mejorada) ===
        $faq       = $this->findFaq($userText);       // puede ser null
        $recurso   = $this->findRecurso($userText);   // puede ser null
        $botEmisor = EmisorHelper::valueFor('bot');

        // === Armamos contexto de documentos (FAQS / RECURSOS) para el LLM ===
        $docsContext = [];
        $idFaq = null;
        $idRecurso = null;

        if ($faq) {
            $docsContext[] = [
                'tipo'      => 'FAQ',
                'titulo'    => $faq->pregunta ?? '',
                'contenido' => $faq->respuesta ?? '',
            ];
            $idFaq = (int) $faq->id_faq;
        }

        if ($recurso) {
            // Incluimos descripción + URL en el contenido para que lo pueda envolver
            $contenidoRecurso = trim(($recurso->descripcion ?? '') . "\nURL: " . ($recurso->url ?? ''));
            $docsContext[] = [
                'tipo'      => 'RECURSO',
                'titulo'    => $recurso->titulo ?? '',
                'contenido' => $contenidoRecurso,
            ];
            $idRecurso = (int) $recurso->id_recurso;
        }

        // === Historial de chat: últimos 10 mensajes de esta conversación ===
        $emisorUserValue = EmisorHelper::valueFor('user');

        $history = Mensaje::where('id_conversacion', $conv->id_conversacion)
            ->orderBy('fecha_envio', 'desc')
            ->limit(10)
            ->get()
            ->sortBy('fecha_envio')  // lo dejamos en orden cronológico
            ->map(function (Mensaje $m) use ($emisorUserValue) {
                return [
                    'role'    => $m->emisor === $emisorUserValue ? 'user' : 'assistant',
                    'content' => $m->contenido,
                ];
            })
            ->values()
            ->all();

        // === SIEMPRE usamos el LLM, con:
        // - userText (pregunta actual)
        // - docsContext (FAQ/RECURSOS si los hay)
        // - history (últimos 10 mensajes)
        $botText = $this->bot->answerWithLLM($userText, $docsContext, $history);

        $botMsg = null;

        // Solo guardo si hay FAQ o RECURSO por la restricción de la BD
        if ($idFaq !== null || $idRecurso !== null) {
            $botMsg = Mensaje::create([
                'id_conversacion' => $conv->id_conversacion,
                'emisor'          => $botEmisor,
                'contenido'       => $botText,
                'fecha_envio'     => now(),
                'id_faq'          => $idFaq,
                'id_recurso'      => $idRecurso,
            ]);
        }

        return response()->json([
            'ok'             => true,
            'conversationId' => $conv->id_conversacion,
            'userMessageId'  => $userMsg->id_mensaje,
            'botMessageId' => $botMsg ? $botMsg->id_mensaje : null,
            'reply'          => ['type' => 'text', 'content' => $botText],
        ]);
    }

    /* ===================== Helpers ===================== */

    /**
     * Extrae palabras clave “útiles” desde la pregunta del usuario.
     */
    private function keywords(string $q): array
    {
        $q = mb_strtolower($q, 'UTF-8');
        // reemplazo signos por espacio
        $q = preg_replace('/[^\p{L}\p{N}\s]+/u', ' ', $q);
        $parts = preg_split('/\s+/', $q, -1, PREG_SPLIT_NO_EMPTY);

        // stopwords básicas en español (ampliadas)
        $stopwords = [
            'el','la','los','las','un','una','unos','unas',
            'de','del','al','a','en','por','para','con','sobre',
            'y','o','u','que','como','cual','cuales',
            'es','son','hay','si','no','se','lo','su','sus',
            'donde','dónde','cuando','cuándo',
            // añadimos verbos/palabras que ensucian búsquedas de manuales:
            'hago','hacer','puedo','quiero','necesito','tengo','tiene',
            'manual','guia','guía','ayuda'
        ];

        $keywords = array_filter($parts, function ($w) use ($stopwords) {
            return mb_strlen($w, 'UTF-8') >= 3 && !in_array($w, $stopwords, true);
        });

        return array_values(array_unique($keywords));
    }

    /**
     * Búsqueda simple de FAQ por texto del usuario.
     * Antes usaba AND sobre todas las palabras, ahora usamos OR para ser más permisivos.
     */
    private function findFaq(string $q): ?object
    {
        $keywords = $this->keywords($q);
        if (empty($keywords)) {
            return null;
        }

        return DB::table('FAQS')
            ->select('id_faq', 'pregunta', 'respuesta')
            ->where(function ($query) use ($keywords) {
                $query->where(function ($sub) use ($keywords) {
                    foreach ($keywords as $word) {
                        $like = '%' . $word . '%';
                        // usamos OR entre palabras para aumentar el recall
                        $sub->orWhere('pregunta', 'LIKE', $like)
                            ->orWhere('respuesta', 'LIKE', $like);
                    }
                });
            })
            ->orderBy('id_faq', 'ASC')
            ->first();
    }

    /**
     * Búsqueda simple de RECURSO por texto del usuario.
     */
    private function findRecurso(string $q): ?object
    {
        $keywords = $this->keywords($q);
        if (empty($keywords)) {
            return null;
        }

        return DB::table('RECURSOS')
            ->select('id_recurso', 'titulo', 'descripcion', 'url')
            ->where(function ($query) use ($keywords) {
                $query->where(function ($sub) use ($keywords) {
                    foreach ($keywords as $word) {
                        $like = '%' . $word . '%';
                        $sub->orWhere('titulo', 'LIKE', $like)
                            ->orWhere('descripcion', 'LIKE', $like);
                    }
                });
            })
            ->orderBy('id_recurso', 'ASC')
            ->first();
    }

    private function armaRespuestaFaq(object $faq): string
    {
        $p = trim($faq->pregunta ?? '');
        $r = trim($faq->respuesta ?? '');
        return "🔹 *FAQ*\n\n*Pregunta:* {$p}\n*Respuesta:* {$r}";
    }

    private function armaRespuestaRecurso(object $rec): string
    {
        $titulo = trim($rec->titulo ?? '(sin título)');
        $desc   = trim($rec->descripcion ?? '');
        $url    = trim($rec->url ?? '');
        $body   = $desc ? "{$desc}\n{$url}" : $url;
        return "🔗 *Recurso*: {$titulo}\n{$body}";
    }
}
