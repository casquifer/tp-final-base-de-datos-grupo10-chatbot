<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class EstadoConversacion extends Model {
    protected $table = 'ESTADOS_CONVERSACION';
    protected $primaryKey = 'id_estado';
    public $timestamps = false;
    protected $fillable = ['nombre','descripcion'];
}
