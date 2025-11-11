<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class LlmService
{
    protected string $baseUrl;
    protected string $model;

    public function __construct()
    {
        $this->baseUrl = rtrim(env('LLM_BASE_URL', 'http://ollama:11434'), '/');
        $this->model   = env('LLM_MODEL', 'llama3.2:1b');
    }

    /**
     * Envía un chat a Ollama (sin stream) respetando mensajes system|user|assistant
     * @param array<int, array{role:string, content:string}> $messages
     */
    public function chat(array $messages): string
    {
        // Sanitiza contenidos a string llano
        $messages = array_map(function ($m) {
            return [
                'role'    => $m['role'],
                'content' => is_string($m['content']) ? $m['content'] : json_encode($m['content'], JSON_UNESCAPED_UNICODE),
            ];
        }, $messages);

        $payload = [
            'model'    => $this->model,
            'messages' => $messages,
            'stream'   => false,
            'options'  => [
                'temperature' => 0.2,
            ],
        ];

        $resp = Http::timeout(120)
            ->acceptJson()
            ->post("{$this->baseUrl}/api/chat", $payload);

        if (!$resp->ok()) {
            // Si Ollama no tiene el modelo o hay OOM, devolvemos un texto claro
            $body = $resp->body();
            return "No pude usar el modelo por ahora. Detalle: {$body}";
        }

        $json = $resp->json();

        // Respuesta estándar de /api/chat: { "message": { "role": "...", "content": "..." }, ... }
        $content = data_get($json, 'message.content');
        if (is_string($content) && $content !== '') {
            return $content;
        }

        // Algunas variantes devuelven 'response'
        $fallback = data_get($json, 'response');
        if (is_string($fallback) && $fallback !== '') {
            return $fallback;
        }

        return 'No obtuve respuesta del modelo.';
    }
}
