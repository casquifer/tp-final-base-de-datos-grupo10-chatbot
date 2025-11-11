<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Conversacion extends Model
{
    protected $table = 'CONVERSACIONES';
    protected $primaryKey = 'id_conversacion';
    public $timestamps = false;

    protected $fillable = [
    'id_usuario', 'estado', 'motivo_cierre', 'fecha_inicio', 'fecha_cierre', 'escalada_a'
    ];

    protected $casts = [
    'fecha_inicio' => 'datetime',
    'fecha_cierre' => 'datetime',
    ];

}
