<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class BotService
{
    /**
     * @param string $userText   Pregunta actual del usuario
     * @param array  $docsContext Array de docs tipo:
     *                            [
     *                              ['tipo' => 'FAQ', 'titulo' => '...', 'contenido' => '...'],
     *                              ['tipo' => 'RECURSO', 'titulo' => '...', 'contenido' => '...'],
     *                            ]
     * @param array  $history     Array de últimos mensajes:
     *                            [
     *                              ['role' => 'user'|'assistant', 'content' => '...'],
     *                              ...
     *                            ]
     */
    public function answerWithLLM(string $userText, array $docsContext = [], array $history = []): string
    {
        $model   = config('services.ollama.model', env('LLM_MODEL', 'llama3.2:3b'));
        $baseUrl = rtrim(env('OLLAMA_BASE_URL', 'http://ollama:11434'), '/');

        // ===== Contexto de documentos (FAQS / RECURSOS) =====
        $snippets = [];
        foreach ($docsContext as $i => $c) {
            if ($i >= 4) break; // máximo 4 bloques de contexto
            $tipo      = $c['tipo']      ?? 'Doc';
            $titulo    = $c['titulo']    ?? '(sin título)';
            $contenido = $c['contenido'] ?? '';
            $snippets[] = "- {$tipo}: {$titulo}\n{$contenido}";
        }

        $ctxParts = [];

        if (!empty($snippets)) {
            $ctxParts[] = "Contexto interno (guías oficiales FAQS/RECURSOS):\n"
                . implode("\n\n", $snippets);
        }

        // ===== Historial reciente de la conversación =====
        if (!empty($history)) {
            $lines = [];
            foreach ($history as $turn) {
                $role    = $turn['role'] ?? 'user';
                $speaker = $role === 'assistant' ? 'Boticcelli' : 'Usuario';
                $content = $turn['content'] ?? '';
                $lines[] = "{$speaker}: {$content}";
            }

            $ctxParts[] = "Historial reciente de la conversación (últimos "
                . count($history) . " mensajes):\n"
                . implode("\n", $lines);
        }

        $ctx = $ctxParts
            ? (implode("\n\n", $ctxParts) . "\n")
            : "Contexto interno: (vacío)\n";

        // ===== System prompt =====
        $system = <<<SYS
Sos Boticcelli, asistente del sistema UNSAM. Respondés siempre en español rioplatense, breve y claro. Agregá algunos emojis a las respuestas (1 o 2, no más).

Reglas generales:

1) Si el contexto de guías (FAQS/RECURSOS) NO está vacío:
   - Considerá esos textos como la única fuente de verdad.
   - Respondé usando SOLO la información de esas guías.
   - Podés parafrasear en tus palabras, pero NO inventes datos nuevos.
   - Si un recurso contiene un link, mencioná el título y el link al final en una línea separada.

2) Podés usar el historial reciente de conversación solo para mantener continuidad
   (por ejemplo, recordar qué se venía hablando), pero nunca para inventar reglas o datos
   que no estén en las guías internas.

3) Si el contexto de guías está vacío:
   - Si es un saludo o te preguntan quién sos, presentate brevemente como Boticcelli y ofrecé ayuda.
   - Si la pregunta es sobre UNSAM, sistemas, alumnos, docentes, aulas virtuales, usuarios, claves, etc.
     pero no tenés datos concretos, respondé algo como:
     "No encontré información en mis guías internas sobre esto. ¿Querés que genere un ticket para que te contacten?"
   - Si la pregunta es sobre temas ajenos a UNSAM (personas específicas, chistes, opiniones personales, etc.),
     aclarar cortito que solo podés ayudar con consultas sobre los sistemas y servicios de UNSAM
     y ofrecé redirigir la conversación a algo útil.

4) No inventes restricciones raras del tipo "no puedo responder preguntas que contengan el término X".
   Si no tenés info suficiente en las guías, decí simplemente que no la encontraste y ofrecé generar un ticket.

5) No digas que sos un modelo de IA genérico; siempre sos Boticcelli, asistente del sistema UNSAM.

Respuestas de 1 a 3 frases máximo.
SYS;

        $prompt = $ctx . "\nUsuario pregunta ahora: «{$userText}»";

        $payload = [
            'model'    => $model,
            'messages' => [
                ['role' => 'system', 'content' => $system],
                ['role' => 'user',   'content' => $prompt],
            ],
            'stream'  => false,
            'options' => [
                'temperature' => 0.1,   // bajo = menos alucinaciones
                'top_p'       => 0.9,
                'num_ctx'     => 2048,
            ],
        ];

        try {
            $resp = Http::timeout(20)->post("{$baseUrl}/api/chat", $payload);

            if (! $resp->ok()) {
                return "No pude consultar al modelo en este momento. Probá de nuevo o decime si genero un ticket.";
            }

            $data = $resp->json();
            $text = $data['message']['content']
                ?? ($data['choices'][0]['message']['content'] ?? null);

            return $text ?: "Se generó un inconveniente con la respuesta. ¿Querés que genere un ticket?";
        } catch (\Throwable $e) {
            // Podés loguear $e->getMessage() si querés
            return "No pude consultar al modelo en este momento. Probá de nuevo o decime si genero un ticket.";
        }
    }
}
