<?php

namespace App\Http\Controllers;

use App\Models\Conversacion;
use App\Models\Mensaje;
use App\Models\Ticket;
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
            'history'        => 'array',              // lo dejamos por compatibilidad con el front
            'conversationId' => 'nullable|integer',
        ]);

        $userId         = (int) $data['userId'];
        $userText       = trim($data['message']);
        $conversationId = $data['conversationId'] ?? null;

        // ======================================================
        // 0) Resolver conversación: nueva si no hay o si está cerrada
        // ======================================================
        $estadoActivaId = $this->estadoConversacionId('activa');

        $conv = null;

        if ($conversationId) {
            $conv = Conversacion::find($conversationId);
        }

        if (! $conv) {
            // buscamos la última conversación de ese usuario
            $conv = Conversacion::where('id_usuario', $userId)
                ->orderBy('id_conversacion', 'DESC')
                ->first();
        }

        if (! $conv || (int)$conv->estado !== (int)$estadoActivaId) {
            // no hay conversación previa o la última está cerrada → creamos una nueva
            $conv = Conversacion::create([
                'id_usuario'    => $userId,
                'estado'        => $estadoActivaId,
                'motivo_cierre' => null,
                'fecha_cierre'  => null,
                'escalada_a'    => null,
            ]);
        }

        // ======================================================
        // Mensaje del usuario
        // ======================================================
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
                'enum'   => EmisorHelper::enumValues(),
                'intent' => $userEmisor,
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

        // ======================================================
        // 1) ¿El usuario está pidiendo/aceptando generar un ticket?
        // ======================================================
        if ($this->isTicketRequest($userText)) {
            $ticket = $this->crearTicketDesdeConversacion($conv, $userId, $userText);

            $botEmisor = EmisorHelper::valueFor('bot');

            $botText = "Listo, te generé el ticket número {$ticket->id_ticket} ✅. "
                     . "Lo van a revisar y se van a contactar con vos si hace falta.";

            // Intentamos guardar el mensaje del bot (si tu tabla MENSAJES permite id_faq/id_recurso NULL)
            try {
                $botMsg = Mensaje::create([
                    'id_conversacion' => $conv->id_conversacion,
                    'emisor'          => $botEmisor,
                    'contenido'       => $botText,
                    'fecha_envio'     => now(),
                    'id_faq'          => null,
                    'id_recurso'      => null,
                ]);
            } catch (\Throwable $e) {
                Log::error('Insert MENSAJES (bot ticket) falló: '.$e->getMessage());
                $botMsg = null;
            }

            // Historial (por si lo necesitás en el front)
            $emisorUserValue = EmisorHelper::valueFor('user');

            $history = Mensaje::where('id_conversacion', $conv->id_conversacion)
                ->orderBy('fecha_envio', 'desc')
                ->limit(10)
                ->get()
                ->sortBy('fecha_envio')  // orden cronológico
                ->map(function (Mensaje $m) use ($emisorUserValue) {
                    return [
                        'role'    => $m->emisor === $emisorUserValue ? 'user' : 'assistant',
                        'content' => $m->contenido,
                    ];
                })
                ->values()
                ->all();

            return response()->json([
                'ok'             => true,
                'conversationId' => $conv->id_conversacion,
                'userMessageId'  => $userMsg->id_mensaje,
                'botMessageId'   => $botMsg ? $botMsg->id_mensaje : null,
                'ticketId'       => $ticket->id_ticket,
                'reply'          => [
                    'type'    => 'text',
                    'content' => $botText,
                ],
                'history'        => $history,
            ]);
        }

        // ======================================================
        // 2) Si no es pedido de ticket: flujo normal FAQ/RECURSOS + LLM
        // ======================================================
        $faq     = $this->findFaq($userText);      // puede ser null
        $recurso = $this->findRecurso($userText);  // puede ser null

        $botEmisor = EmisorHelper::valueFor('bot');

        $idFaq     = $faq ? (int) $faq->id_faq : null;
        $idRecurso = $recurso ? (int) $recurso->id_recurso : null;

        $botText = null;

        if ($faq || $recurso) {
            // --- Caso A: tenemos datos en BD, armamos respuesta base ---
            $partes = [];

            if ($faq) {
                $partes[] = $this->armaRespuestaFaq($faq);
            }

            if ($recurso) {
                $partes[] = $this->armaRespuestaRecurso($recurso);
            }

            $contenidoBase = implode("\n\n", $partes);

            // Que Boticcelli lo parafrasee usando SOLO las guías
            $botText = $this->bot->responderDesdeGuia($userText, $contenidoBase);
        } else {
            // --- Caso B: no hay guías, no encontramos nada en FAQS/RECURSOS ---
            $botText = $this->bot->repreguntarSinGuia($userText);
        }

        // Historial (solo para el front, no se lo mandamos al modelo)
        $emisorUserValue = EmisorHelper::valueFor('user');

        $history = Mensaje::where('id_conversacion', $conv->id_conversacion)
            ->orderBy('fecha_envio', 'desc')
            ->limit(10)
            ->get()
            ->sortBy('fecha_envio')  // orden cronológico
            ->map(function (Mensaje $m) use ($emisorUserValue) {
                return [
                    'role'    => $m->emisor === $emisorUserValue ? 'user' : 'assistant',
                    'content' => $m->contenido,
                ];
            })
            ->values()
            ->all();

        // Guardamos respuesta del bot SOLO si hay FAQ o RECURSO (por restricción BD)
        $botMsg = null;

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
            'botMessageId'   => $botMsg ? $botMsg->id_mensaje : null,
            'reply'          => [
                'type'    => 'text',
                'content' => $botText,
            ],
            'history'        => $history,
        ]);
    }

    /* ===================== Helpers ===================== */

    /**
     * Detecta si el usuario está pidiendo/aceptando generar un ticket.
     */
    private function isTicketRequest(string $text): bool
    {
        $t = mb_strtolower($text, 'UTF-8');

        // Si menciona "ticket" junto con algún verbo típico
        if (str_contains($t, 'ticket')) {
            if (str_contains($t, 'gener')
                || str_contains($t, 'crear')
                || str_contains($t, 'abrir')
                || str_contains($t, 'abrí')
                || str_contains($t, 'iniciar')
                || str_contains($t, 'sacar')
            ) {
                return true;
            }
        }

        // Respuestas cortas típicas después de que el bot propone ticket
        $solo = trim($t);
        $respuestasSi = [
            'si', 'sí', 'dale', 'ok', 'ok.', 'ok!', 'genial',
            'perfecto', 'por favor', 'porfis', 'si, por favor', 'sí, por favor',
        ];

        if (in_array($solo, $respuestasSi, true)) {
            return true;
        }

        return false;
    }

    /**
     * Crea un ticket a partir de la conversación y el último mensaje del usuario,
     * y CIERRA la conversación.
     */
    private function crearTicketDesdeConversacion(Conversacion $conv, int $userId, string $userText): Ticket
    {
        $destinoId = config('tickets.default_destino', 1);

        $asunto = mb_substr($userText, 0, 160, 'UTF-8');
        $resumen = $userText;

        // Solo los últimos tres mensajes en el transcript
        $transcript = $this->buildTranscriptUltimos3($conv);

        $ticket = Ticket::create([
            'id_conversacion'  => $conv->id_conversacion,
            'id_usuario'       => $userId,
            'id_destino'       => $destinoId,
            'asunto'           => $asunto,
            'resumen'          => $resumen,
            'contacto_usuario' => null,
            'transcript_texto' => $transcript,
            'referencia_externa' => null,
        ]);

        // Cerrar conversación
        $estadoCerradaId = $this->estadoConversacionId('cerrada');

        $conv->estado       = $estadoCerradaId;
        $conv->motivo_cierre = null;       // si querés, después lo podemos configurar
        $conv->fecha_cierre  = now();
        $conv->save();

        return $ticket;
    }

    /**
     * Últimos 3 mensajes (usuario o bot) en orden cronológico.
     */
    private function buildTranscriptUltimos3(Conversacion $conv): string
    {
        $emisorUserValue = EmisorHelper::valueFor('user');

        $mensajes = Mensaje::where('id_conversacion', $conv->id_conversacion)
            ->orderBy('fecha_envio', 'DESC')
            ->limit(3)
            ->get()
            ->sortBy('fecha_envio'); // ahora ascendente

        $lineas = [];

        foreach ($mensajes as $m) {
            $rol = ($m->emisor === $emisorUserValue) ? 'Usuario' : 'Asistente';
            $lineas[] = "[{$m->fecha_envio}] {$rol}: {$m->contenido}";
        }

        return implode("\n", $lineas);
    }

    /**
     * Devuelve el id_estado a partir del nombre en ESTADOS_CONVERSACION.
     */
    private function estadoConversacionId(string $nombre): int
    {
        $id = DB::table('ESTADOS_CONVERSACION')
            ->where('nombre', $nombre)
            ->value('id_estado');

        if (! $id) {
            Log::warning('No se encontró estado de conversación, usando 1 por defecto', [
                'nombre' => $nombre,
            ]);
            return 1;
        }

        return (int) $id;
    }

    /**
     * Extrae palabras clave “útiles” desde la pregunta del usuario.
     */
    private function keywords(string $q): array
    {
        $q = mb_strtolower($q, 'UTF-8');
        $q = preg_replace('/[^\p{L}\p{N}\s]+/u', ' ', $q);
        $parts = preg_split('/\s+/', $q, -1, PREG_SPLIT_NO_EMPTY);

        $stopwords = [
            'el','la','los','las','un','una','unos','unas',
            'de','del','al','a','en','por','para','con','sobre',
            'y','o','u','que','como','cual','cuales',
            'es','son','hay','si','no','se','lo','su','sus',
            'donde','dónde','cuando','cuándo',
            'hago','hacer','puedo','quiero','necesito','tengo','tiene',
            'manual','guia','guía','ayuda',
        ];

        $keywords = array_filter($parts, function ($w) use ($stopwords) {
            return mb_strlen($w, 'UTF-8') >= 3 && !in_array($w, $stopwords, true);
        });

        return array_values(array_unique($keywords));
    }

    /**
     * Búsqueda simple de FAQ por texto del usuario (OR entre palabras).
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
                        $sub->orWhere('pregunta', 'LIKE', $like)
                            ->orWhere('respuesta', 'LIKE', $like);
                    }
                });
            })
            ->orderBy('id_faq', 'ASC')
            ->first();
    }

    /**
     * Búsqueda simple de RECURSO por texto del usuario (OR entre palabras).
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



