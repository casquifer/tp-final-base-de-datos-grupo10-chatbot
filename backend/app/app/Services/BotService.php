<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class BotService
{
    protected string $model;
    protected string $baseUrl;

    public function __construct()
    {
        $this->model   = config('services.ollama.model', env('LLM_MODEL', 'llama3.2:3b'));
        $this->baseUrl = rtrim(env('OLLAMA_BASE_URL', 'http://ollama:11434'), '/');
    }

    /**
     * Usa el modelo SOLO para parafrasear contenido oficial (FAQS/RECURSOS).
     *
     * @param string $userText      Pregunta actual del usuario
     * @param string $contenidoGuia Texto armado desde FAQS/RECURSOS
     */
    public function responderDesdeGuia(string $userText, string $contenidoGuia): string
    {
        // Si por alguna razón viene vacío, devolvemos directo el contenido
        if (trim($contenidoGuia) === '') {
            return "No encontré información en mis guías internas sobre esto 🤔. "
                 . "¿Querés que genere un ticket para que te contacten o preferís darme más detalles?";
        }

        $system = <<<SYS
Tu nombre es "Boticcelli", eres asistente del sistema UNSAM. Respondés siempre en español rioplatense, breve y claro. Agregá 1 o 2 emojis, no más.

Usá EXCLUSIVAMENTE la información que te doy como contenido oficial (FAQS/RECURSOS). No inventes datos nuevos.
SYS;

        $userPrompt = <<<TXT
Contenido oficial (FAQS/RECURSOS):

{$contenidoGuia}

---

El usuario preguntó: «{$userText}».

Respondé en 1 o 3 frases claras, amigables, usando SOLO la información del contenido oficial.
TXT;

        $messages = [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user',   'content' => $userPrompt],
        ];

        return $this->callOllama($messages);
    }

    /**
     * Cuando no hay FAQ ni RECURSO: repregunta o invita a iniciar ticket.
     * Acá NO usamos el modelo para evitar alucinaciones y ahorrar recursos.
     */
    public function repreguntarSinGuia(string $userText): string
    {
        $len = mb_strlen($userText, 'UTF-8');

        // Si la consulta es muy corta, primero pedimos más detalle
        if ($len < 20) {
            return "No encontré información concreta en mis guías internas sobre esto 🤔. "
                 . "¿Me contás un poquito más de la consulta así veo si te puedo ayudar mejor?";
        }

        // Si ya es una consulta más larga, ofrecemos directamente el ticket
        return "No encontré información en mis guías internas sobre este tema 😕. "
             . "¿Querés que genere un ticket para que te contacten desde soporte?";
    }

    /**
     * Llamado genérico a Ollama, con logging y timeout más holgado.
     *
     * @param array $messages Mensajes estilo OpenAI/Ollama (system/user/assistant)
     * @param array $options  Opciones extra para el modelo
     */
    protected function callOllama(array $messages, array $options = []): string
    {
        $payload = [
            'model'    => $this->model,
            'messages' => $messages,
            'stream'   => false,
            'options'  => array_merge([
                'temperature' => 0.1,   // bajo = menos alucinaciones
                'top_p'       => 0.9,
                'num_ctx'     => 1024,  // reducimos contexto para no reventar memoria
            ], $options),
        ];

        try {
            $resp = Http::timeout(60)->post("{$this->baseUrl}/api/chat", $payload);

            if (! $resp->ok()) {
                Log::error('Ollama devolvió status no OK', [
                    'status' => $resp->status(),
                    'body'   => $resp->body(),
                ]);

                return "No pude consultar al modelo en este momento 😕. Probá de nuevo o decime si genero un ticket.";
            }

            $data = $resp->json();

            Log::debug('Ollama respondió OK', [
                'data_preview' => $data ? substr(json_encode($data), 0, 2000) : null,
            ]);

            $text = $data['message']['content']
                ?? ($data['choices'][0]['message']['content'] ?? null);

            return $text ?: "Se generó un inconveniente con la respuesta 😅. ¿Querés que genere un ticket?";
        } catch (\Throwable $e) {
            Log::error('Error llamando a Ollama', [
                'msg'   => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return "No pude consultar al modelo en este momento 😕. Probá de nuevo o decime si genero un ticket.";
        }
    }
}
