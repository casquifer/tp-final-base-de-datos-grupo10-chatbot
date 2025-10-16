<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatController extends Controller
{
    public function chat(Request $request)
    {
        $data = $request->validate([
            'userId'  => 'required|integer',
            'message' => 'required|string',
            'history' => 'array'
        ]);

        $ollamaUrl = env('OLLAMA_URL', 'http://ollama:11434');
        $model     = env('LLM_MODEL', 'llama3.2:3b');

        $messages = [
            ['role' => 'system', 'content' => 'Eres un asistente llamado "Boticcelli", tu principal función es ayudar a los usuarios con sus problemáticas 
            con un sistema. Puedes responder sobre utilidades y funciones del sistema, o bien recomendar tutoriales o crear un ticket. Responde claro y breve.'],
        ];

        foreach (($data['history'] ?? []) as $m) {
            if (isset($m['role'], $m['content'])) {
                $messages[] = ['role' => $m['role'], 'content' => $m['content']];
            }
        }
        $messages[] = ['role' => 'user', 'content' => $data['message']];

        try {
            $resp = Http::timeout(120)->post("$ollamaUrl/api/chat", [
                'model'    => $model,
                'messages' => $messages,
                'stream'   => false,
            ]);

            if (!$resp->ok()) {
                return response()->json([
                    'ok' => false,
                    'error' => 'LLM_ERROR',
                    'detail' => $resp->json() ?? $resp->body(),
                ], 500);
            }

            $json  = $resp->json();
            $reply = $json['message']['content'] ?? ($json['response'] ?? '(sin respuesta)');

            return response()->json(['ok' => true, 'reply' => $reply]);
        } catch (\Throwable $e) {
            return response()->json([
                'ok' => false,
                'error' => 'BACKEND_EXCEPTION',
                'detail' => $e->getMessage(),
            ], 500);
        }
    }
}
