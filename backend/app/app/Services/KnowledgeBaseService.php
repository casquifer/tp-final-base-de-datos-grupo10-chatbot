<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

class KbResult {
    public ?array $faq = null;        // ['id_faq','respuesta','categoria']
    /** @var array<int, array{id_recurso:int,titulo:string,url:string}> */
    public array $recursos = [];
    public function hasHit(): bool { return (bool)$this->faq || !empty($this->recursos); }
}

class KnowledgeBaseService
{
    public function search(string $q): KbResult
    {
        $qNorm  = mb_strtolower($q, 'UTF-8');
        $tokens = $this->tokenize($qNorm);

        $res = new KbResult();

        $faqRow = DB::table('FAQS')
            ->where('activa', 1)
            ->where(function ($qb) use ($qNorm, $tokens) {
                $qb->where('pregunta', 'like', "%{$qNorm}%")
                   ->orWhere('respuesta', 'like', "%{$qNorm}%")
                   ->orWhere('categoria', 'like', "%{$qNorm}%");
                foreach ($tokens as $t) {
                    $qb->orWhere('pregunta', 'like', "%{$t}%")
                       ->orWhere('respuesta', 'like', "%{$t}%")
                       ->orWhere('categoria', 'like', "%{$t}%");
                }
            })
            ->orderByDesc('id_faq')
            ->first();

        if ($faqRow) {
            $res->faq = [
                'id_faq'    => (int)$faqRow->id_faq,
                'respuesta' => $faqRow->respuesta,
                'categoria' => $faqRow->categoria,
            ];
        }

        $recQ = DB::table('RECURSOS')->where('activo', 1);
        if ($res->faq && !empty($res->faq['categoria'])) {
            $cat = $res->faq['categoria'];
            $recQ->where(function ($qb) use ($cat) {
                $qb->where('titulo', 'like', "%{$cat}%")
                   ->orWhere('descripcion', 'like', "%{$cat}%");
            });
        } elseif (!empty($tokens)) {
            $recQ->where(function ($qb) use ($tokens) {
                foreach ($tokens as $t) {
                    $qb->orWhere('titulo', 'like', "%{$t}%")
                       ->orWhere('descripcion', 'like', "%{$t}%");
                }
            });
        } else {
            $recQ->whereRaw('1=0');
        }

        $rows = $recQ->orderByDesc('id_recurso')->limit(3)->get();
        foreach ($rows as $r) {
            $res->recursos[] = [
                'id_recurso' => (int)$r->id_recurso,
                'titulo'     => $r->titulo,
                'url'        => $r->url,
            ];
        }
        return $res;
    }

    private function tokenize(string $q): array
    {
        $raw  = preg_split('/\W+/u', $q, -1, PREG_SPLIT_NO_EMPTY);
        $stop = ['el','la','los','las','de','del','y','o','u','para','por','con','en','un','una','unos','unas',
                 'que','como','qué','cual','cuales','cuál','cuáles','donde','dónde','porqué','porque','para qué'];
        return array_values(array_filter($raw, fn($t) => mb_strlen($t) >= 3 && !in_array($t, $stop, true)));
    }
}

