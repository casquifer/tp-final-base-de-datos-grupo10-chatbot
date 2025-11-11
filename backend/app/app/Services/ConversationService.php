<?php

namespace App\Services;

use App\Models\Conversacion;
use App\Models\Escalado;
use App\Models\Mensaje;
use Illuminate\Support\Facades\DB;

class ConversationService
{
    /** Devuelve el id_estado desde ESTADOS_CONVERSACION por nombre */
    private function estadoId(string $nombre): int
    {
        $row = DB::table('ESTADOS_CONVERSACION')->where('nombre', $nombre)->first();
        abort_if(!$row, 500, "Estado '$nombre' no existe en ESTADOS_CONVERSACION");
        return (int) $row->id_estado;
    }

    /** Obtiene o crea la conversación activa del usuario */
    public function getOrCreateActive(int $userId, ?int $conversationId = null): Conversacion
    {
        $idActiva = $this->estadoId('activa');

        return DB::transaction(function () use ($userId, $conversationId, $idActiva): Conversacion {
            if ($conversationId) {
                $conv = Conversacion::lockForUpdate()->find($conversationId);
                abort_if(!$conv || (int) $conv->id_usuario !== $userId, 404, 'CONVERSATION_NOT_FOUND');
                return $conv;
            }

            $conv = Conversacion::lockForUpdate()
                ->where('id_usuario', $userId)
                ->where('estado', $idActiva)        // <-- columna 'estado'
                ->orderByDesc('fecha_inicio')
                ->first();

            if (!$conv) {
                $conv = Conversacion::create([
                    'id_usuario'   => $userId,
                    'fecha_inicio' => now(),
                    'estado'       => $idActiva,     // <-- columna 'estado'
                    'escalada_a'   => null,
                ]);
            }
            return $conv;
        });
    }

    /** Cierra la conversación (opcionalmente con motivo) */
    public function close(int $conversationId, ?int $idMotivoCierre = null): Conversacion
    {
        $idCerrada = $this->estadoId('cerrada');

        return DB::transaction(function () use ($conversationId, $idCerrada, $idMotivoCierre): Conversacion {
            $conv = Conversacion::lockForUpdate()->findOrFail($conversationId);
            $conv->estado       = $idCerrada;      // <-- columna 'estado'
            $conv->fecha_cierre = now();
            if ($idMotivoCierre) {
                $conv->motivo_cierre = $idMotivoCierre; // ajustá el nombre si difiere
            }
            $conv->save();
            return $conv;
        });
    }

    /** Escala la conversación y registra el escalado */
    public function escalate(int $conversationId, ?int $destinoId, string $asunto, string $contacto): array
    {
        $idEscalada = $this->estadoId('escalada');

        return DB::transaction(function () use ($conversationId, $idEscalada, $destinoId, $asunto, $contacto): array {
            $conv = Conversacion::lockForUpdate()->findOrFail($conversationId);
            $conv->estado     = $idEscalada;  // <-- columna 'estado'
            $conv->escalada_a = $destinoId;   // puede ser null
            $conv->save();

            $transcript = $this->buildTranscript($conv->id_conversacion);

            $esc = Escalado::create([
                'id_conversacion'   => $conv->id_conversacion,
                'asunto'            => $asunto,
                'resumen'           => mb_substr($transcript, 0, 1000),
                'contacto_usuario'  => $contacto,
                'transcript_texto'  => $transcript,
                'estado_envio'      => 'pendiente',
                'fecha_envio'       => now(),
            ]);

            return [$conv, $esc];
        });
    }

    /** Arma el transcript de la conversación */
    public function buildTranscript(int $conversationId): string
    {
        $rows = Mensaje::where('id_conversacion', $conversationId)
            ->orderBy('fecha_envio')
            ->get(['emisor', 'contenido', 'id_faq', 'id_recurso', 'fecha_envio']);

        $lines = [];
        foreach ($rows as $m) {
            $when = $m->fecha_envio ? date('Y-m-d H:i', strtotime($m->fecha_envio)) : '';
            if ($m->contenido !== null && $m->contenido !== '') {
                $lines[] = "[{$when}] {$m->emisor}: {$m->contenido}";
            } elseif ($m->id_faq) {
                $lines[] = "[{$when}] bot: (FAQ #{$m->id_faq})";
            } elseif ($m->id_recurso) {
                $lines[] = "[{$when}] bot: (RECURSO #{$m->id_recurso})";
            }
        }
        return implode("\n", $lines);
    }
}
