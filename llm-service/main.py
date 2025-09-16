from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx, os, re
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama:11434")
SYSTEM = """Eres un asistente que traduce preguntas a SQL SEGURO.
- Solo SELECT sobre tablas/vistas permitidas.
- Agrega LIMIT 100 por defecto si no hay LIMIT.
- Si la pregunta es ambigua, responde exactamente: NEED_CLARIFICATION
Esquema (ajústalo a tu BD):
- vista_postulaciones(alumno_id, periodo_id, estado, fecha_inicio, fecha_fin)
- alumnos(id, nombre, email)
- periodos(id, nombre, fecha_inicio, fecha_fin)

Formato de salida: SOLO la sentencia SQL, sin explicaciones.
Ejemplos:
P: ¿Cuántas postulaciones activas hay?
SQL: SELECT COUNT(*) AS total FROM vista_postulaciones WHERE estado='activa';
P: Listame las 10 últimas postulaciones
SQL: SELECT * FROM vista_postulaciones ORDER BY fecha_inicio DESC LIMIT 10;
"""

class NLQuery(BaseModel):
    question: str

app = FastAPI(title="LLM NL2SQL")

@app.post("/nl2sql")
async def nl2sql(q: NLQuery):
    prompt = f"{SYSTEM}\nP: {q.question}\nSQL:"
    try:
        async with httpx.AsyncClient(timeout=120) as client:
            r = await client.post(f"{OLLAMA_URL}/api/generate",
                                  json={"model":"llama3.1:8b","prompt":prompt,"stream":False})
            r.raise_for_status()
            sql = r.json().get("response","").strip()
            if re.search(r'\b(INSERT|UPDATE|DELETE|DROP|TRUNCATE|ALTER)\b', sql, re.I):
                sql = "SELECT 'BLOCKED_NON_SELECT' AS reason"
            return {"sql": sql}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
