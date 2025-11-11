<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

class Catalogos
{
    public static function estadoId(string $nombre): ?int
    {
        $row = DB::table('ESTADOS_CONVERSACION')->where('nombre', $nombre)->first();
        return $row ? (int)$row->id_estado : null;
    }

    public static function seedEstado(string $nombre, string $descripcion): int
    {
        return (int) DB::table('ESTADOS_CONVERSACION')->insertGetId([
            'nombre'      => $nombre,
            'descripcion' => $descripcion,
        ]);
    }
}

