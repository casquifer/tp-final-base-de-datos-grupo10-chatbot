<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ticket extends Model
{
    protected $table = 'TICKETS';
    protected $primaryKey = 'id_ticket';

    // La columna fecha_envio la maneja la BD (CURRENT_TIMESTAMP)
    public $timestamps = false;

    protected $fillable = [
        'id_conversacion',
        'id_usuario',
        'id_destino',
        'asunto',
        'resumen',
        'contacto_usuario',
        'transcript_texto',
        'estado_envio',
        'referencia_externa',
    ];
}
