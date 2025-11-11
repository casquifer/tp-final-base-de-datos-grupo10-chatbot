<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mensaje extends Model
{
    protected $table = 'MENSAJES';
    protected $primaryKey = 'id_mensaje';
    public $timestamps = false;

    protected $fillable = [
        'id_conversacion',
        'emisor',        // 'usuario' | 'bot' (según tu schema)
        'contenido',
        'id_faq',
        'id_recurso',
        'fecha_envio',
    ];
}

