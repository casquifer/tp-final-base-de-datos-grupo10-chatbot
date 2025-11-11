<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class BotService
{
    public function answerWithLLM(string $userText, array $context = []): string
    {
        $model = config('services.ollama.model', env('LLM_MODEL', 'llama3.2:1b'));
        $baseUrl = rtrim(env('OLLAMA_BASE_URL', 'http://ollama:11434'), '/');

        // Contexto formateado para el sistema (máx 3-4 ítems)
        $snippets = [];
        foreach ($context as $i => $c) {
            if ($i >= 4) break;
            $snippets[] = "- {$c['tipo']}: {$c['titulo']}\n{$c['contenido']}";
        }
        $ctx = $snippets ? ("Contexto interno:\n" . implode("\n\n", $snippets) . "\n") : "Contexto interno: (vacío)\n";

        $system = <<<SYS
Sos **Boticcelli**, asistente del sistema UNSAM. Respuestas **en español rioplatense**, breves y útiles.
Reglas:
- Si el *contexto interno* contiene la respuesta, usalo literalmente (sin inventar).
- Si falta información: hacé **una** repregunta concreta o indicá qué datos aportar.
- Si no podés resolver, ofrecé abrir un ticket: "¿Querés que genere un ticket para que te contacten?".
- No hables de “soy un modelo de IA genérico”; presentate como Boticcelli.
SYS;

        $prompt = $ctx . "\nUsuario pregunta: «{$userText}»";

        $payload = [
            'model'   => $model,
            'messages'=> [
                ['role' => 'system',    'content' => $system],
                ['role' => 'user',      'content' => $prompt],
            ],
            'stream'  => false,
            // sin parámetros “caros”: mantenemos footprint bajo
            'options' => [
                'temperature' => 0.2,
                'top_p'       => 0.9,
                'num_ctx'     => 2048
            ]
        ];

        try {
            $resp = Http::timeout(20)->post("{$baseUrl}/api/chat", $payload);
            if (!$resp->ok()) {
                return "No pude consultar al modelo en este momento. Probá de nuevo o decime si genero un ticket.";
            }
            $data = $resp->json();
            // ollama devuelve `message.content` o `choices[0].message.content` (según versión)
            $text = $data['message']['content'] ?? ($data['choices'][0]['message']['content'] ?? null);
            return $text ?: "Se generó un inconveniente con la respuesta. ¿Querés que genere un ticket?";
        } catch (\Throwable $e) {
            return "No pude consultar al modelo en este momento. Probá de nuevo o decime si genero un ticket.";
        }
    }
}




