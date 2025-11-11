<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EmisorHelper
{
    /** Devuelve las opciones del ENUM para MENSAJES.emisor */
    public static function enumValues(): array
    {
        $row = DB::table('information_schema.COLUMNS')
            ->select('COLUMN_TYPE')
            ->where('TABLE_SCHEMA', DB::getDatabaseName())
            ->where('TABLE_NAME', 'MENSAJES')
            ->where('COLUMN_NAME', 'emisor')
            ->first();

        if (!$row || !isset($row->COLUMN_TYPE)) return [];

        // COLUMN_TYPE ej: "enum('U','B')" o "enum('user','bot')"
        $type = $row->COLUMN_TYPE;
        if (preg_match_all("/'([^']+)'/", $type, $m)) {
            return $m[1]; // ['U','B'] o ['user','bot']
        }
        return [];
    }

    /**
     * Dado 'user' | 'bot' normaliza al valor permitido por el ENUM.
     * Si no encuentra match, devuelve la primera opción del enum (fallback).
     */
    public static function valueFor(string $role): ?string
    {
        $role = strtolower(trim($role));          // 'user' | 'bot'
        $enum = self::enumValues();

        if (empty($enum)) {
            Log::warning('EmisorHelper: enum MENSAJES.emisor vacío/no hallado, devolviendo null');
            return null;
        }

        // Mapeos posibles
        $candidatosUser = ['u','user','usuario'];
        $candidatosBot  = ['b','bot','asistente','ia'];

        $want = $role === 'bot' ? $candidatosBot : $candidatosUser;

        // 1) Coincidencia exacta (case-insensitive)
        foreach ($enum as $opt) {
            if (in_array(strtolower($opt), $want, true)) return $opt;
        }
        // 2) Coincidencia por inicial (ej. 'U' o 'B')
        foreach ($enum as $opt) {
            if (in_array(strtolower(substr($opt,0,1)), $want, true)) return $opt;
        }

        // 3) Fallback: primera opción válida para no romper el insert
        Log::warning('EmisorHelper: sin match para role='.$role.' en enum=['.implode(',', $enum).'] . Usando fallback='.$enum[0]);
        return $enum[0];
    }
}

