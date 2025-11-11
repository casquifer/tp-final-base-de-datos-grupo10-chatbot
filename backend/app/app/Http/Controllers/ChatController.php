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

        // Conversación
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
                'enum' => EmisorHelper::enumValues(), 'intent' => $userEmisor
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

        // Retrieval desde tablas
        [$bestFaq, $faqScore, $faqAlt]         = $this->bestFaq($userText);
        [$bestRecurso, $recursoScore, $recAlt] = $this->bestRecurso($userText);
        $minFaq = 0.55; $minRecurso = 0.55;

        $botEmisor = EmisorHelper::valueFor('bot');

        if ($bestFaq && $faqScore >= $minFaq && $faqScore >= $recursoScore) {
            $botText = $this->armaRespuestaFaq($bestFaq);
            Mensaje::create([
                'id_conversacion' => $conv->id_conversacion,
                'emisor'          => $botEmisor,
                'contenido'       => $botText,
                'fecha_envio'     => now(),
                'id_faq'          => (int)$bestFaq->id_faq,
                'id_recurso'      => null,
            ]);
            return response()->json([
                'ok' => true,
                'conversationId' => $conv->id_conversacion,
                'userMessageId'  => $userMsg->id_mensaje,
                'reply' => ['type' => 'text', 'content' => $botText]
            ]);
        }

        if ($bestRecurso && $recursoScore >= $minRecurso) {
            $botText = $this->armaRespuestaRecurso($bestRecurso);
            Mensaje::create([
                'id_conversacion' => $conv->id_conversacion,
                'emisor'          => $botEmisor,
                'contenido'       => $botText,
                'fecha_envio'     => now(),
                'id_faq'          => null,
                'id_recurso'      => (int)$bestRecurso->id_recurso,
            ]);
            return response()->json([
                'ok' => true,
                'conversationId' => $conv->id_conversacion,
                'userMessageId'  => $userMsg->id_mensaje,
                'reply' => ['type' => 'text', 'content' => $botText]
            ]);
        }

        // LLM con contexto (sin persistir bot)
        $context = array_merge($faqAlt, $recAlt);
        $llmText = $this->bot->answerWithLLM($userText, $context);

        return response()->json([
            'ok' => true,
            'conversationId' => $conv->id_conversacion,
            'userMessageId'  => $userMsg->id_mensaje,
            'reply' => ['type' => 'text', 'content' => $llmText]
        ]);
    }

    /* ===================== Helpers ===================== */

    private function norm(string $s): string {
        $s = mb_strtolower($s, 'UTF-8');
        $s = preg_replace('/\s+/', ' ', $s);
        return trim($s);
    }

    private function score(string $query, string $text): float
    {
        $q = $this->norm($query);
        $t = $this->norm($text);
        similar_text($q, $t, $pct);
        return $pct / 100.0;
    }

    private function bestFaq(string $q): array
    {
        $rows = DB::table('FAQS')
            ->select('id_faq','pregunta','respuesta')
            ->whereNotNull('pregunta')
            ->limit(1000)
            ->get();

        $best = null; $bestScore = 0.0;
        $alts = [];
        foreach ($rows as $r) {
            $txt = $r->pregunta . ' ' . ($r->respuesta ?? '');
            $s = $this->score($q, $txt);
            $alts[] = [
                'tipo'      => 'FAQ',
                'titulo'    => $r->pregunta,
                'contenido' => $r->respuesta ?? '',
                'score'     => $s,
                'id'        => $r->id_faq
            ];
            if ($s > $bestScore) { $bestScore = $s; $best = $r; }
        }
        usort($alts, fn($a,$b) => $b['score'] <=> $a['score']);

        return [$best, $bestScore, array_slice($alts, 0, 3)];
    }

    private function bestRecurso(string $q): array
    {
        $rows = DB::table('RECURSOS')
            ->select('id_recurso','titulo','descripcion','url')
            ->limit(1000)
            ->get();

        $best = null; $bestScore = 0.0;
        $alts = [];
        foreach ($rows as $r) {
            $txt = ($r->titulo ?? '') . ' ' . ($r->descripcion ?? '');
            $s = $this->score($q, $txt);
            $alts[] = [
                'tipo'      => 'RECURSO',
                'titulo'    => $r->titulo ?? '(sin título)',
                'contenido' => trim(($r->descripcion ?? '') . ' ' . ($r->url ?? '')),
                'score'     => $s,
                'id'        => $r->id_recurso
            ];
            if ($s > $bestScore) { $bestScore = $s; $best = $r; }
        }
        usort($alts, fn($a,$b) => $b['score'] <=> $a['score']);

        return [$best, $bestScore, array_slice($alts, 0, 3)];
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


