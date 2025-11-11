<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Escalado extends Model
{
    protected $table = 'ESCALADOS';
    protected $primaryKey = 'id_escalado';
    public $timestamps = false;

    protected $fillable = [
        'id_conversacion','id_usuario','id_destino',
        'asunto','descripcion','contacto_destino',
        'transcripcion','estado_envio','referencia_externa',
        'fecha_creacion','fecha_envio'
    ];
}
