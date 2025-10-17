from fastapi import FastAPI, Query, HTTPException
from langchain_community.chat_models import ChatOllama
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.schema import StrOutputParser
import mysql.connector
from contextlib import contextmanager
import os
import time

# ---------------------------------------------------------
# 🚀 Configuración general
# ---------------------------------------------------------
app = FastAPI(title="Chatbot - FAQs (Ollama Local)")

# Configuración de conexión a MySQL
MYSQL_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "mysql"),           # nombre del servicio en docker-compose
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", "santi"),
    "database": os.getenv("MYSQL_DATABASE", "prueba")
}

# Configuración del modelo local de Ollama
llm = ChatOllama(
    base_url="http://ollama:11434",  # nombre del contenedor en docker
    model="llama3.2:3b",
    temperature=0.3
)

# ---------------------------------------------------------
# 🔌 Conexión a la base de datos
# ---------------------------------------------------------
@contextmanager
def get_db_connection(retries=10, delay=3):
    conn = None
    for i in range(retries):
        try:
            conn = mysql.connector.connect(**MYSQL_CONFIG)
            yield conn
            break
        except mysql.connector.Error:
            if i == retries - 1:
                raise HTTPException(status_code=503, detail="No se pudo conectar a la base de datos")
            print(f"MySQL no listo, reintentando en {delay}s... ({i+1}/{retries})")
            time.sleep(delay)
    if conn and conn.is_connected():
        conn.close()

# ---------------------------------------------------------
# 🧩 Función principal: responder FAQs con contexto de la BBDD
# ---------------------------------------------------------
def responder_faqs(pregunta: str, usuario: str = "anonimo") -> str:
    with get_db_connection() as db:
        cursor = db.cursor(dictionary=True)
        # Obtener FAQs
        cursor.execute("SELECT pregunta, respuesta FROM FAQs")
        faqs = cursor.fetchall()

        # Obtener últimos 10 mensajes del usuario
        cursor.execute(
            "SELECT entrada, salida FROM logs WHERE usuario=%s ORDER BY fecha DESC LIMIT 10",
            (usuario,)
        )
        historial = cursor.fetchall()
        cursor.close()

    # Construir bloques de contexto
    contexto_faqs = "\n\n".join([f"Q: {f['pregunta']}\nA: {f['respuesta']}" for f in faqs])

    # Extraer hechos conocidos del historial (ej: "X es Y")
    hechos = []
    for h in historial[::-1]:
        texto = h['entrada'].strip()
        if " es " in texto:
            hechos.append(texto)
    contexto_hechos = "\n".join([f"Hecho conocido: {f}" for f in hechos])

    # Historial de conversación
    contexto_chat = "\n".join([f"Usuario: {h['entrada']}\nAsistente: {h['salida']}" for h in historial[::-1]])

    # Contexto total
    contexto_total = f"{contexto_faqs}\n\nHechos previos:\n{contexto_hechos}\n\nHistorial reciente:\n{contexto_chat}"

    # Prompt combinando todo
    prompt_template = PromptTemplate.from_template(
        """
        Eres un asistente experto en atención al cliente.
        Tené en cuenta toda la información disponible y respondé de manera clara, breve y amable.
        Usá los hechos previos como información confiable al responder preguntas sobre personas, lugares o definiciones.
        Recuerda utilizar oraciones cortas para no perder la atención del usuario.

        Información relevante:
        {contexto_total}

        Pregunta del usuario:
        {pregunta}

        Responde en tono cordial, clara y directa:
        """
    )

    # Invocar modelo
    chain = prompt_template | llm | StrOutputParser()
    respuesta = chain.invoke({"contexto_total": contexto_total, "pregunta": pregunta}).strip()

    # Guardar pregunta y respuesta en logs
    with get_db_connection() as db:
        cursor = db.cursor()
        cursor.execute(
            "INSERT INTO logs (usuario, entrada, salida) VALUES (%s, %s, %s)",
            (usuario, pregunta, respuesta)
        )
        db.commit()
        cursor.close()

    return respuesta



"""def responder_faqs(pregunta: str) -> str:
    with get_db_connection() as db:
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT pregunta, respuesta FROM FAQs")
        faqs = cursor.fetchall()
        cursor.close()

    if not faqs:
        return "No encontré información relevante en las FAQs."

    contexto = "\n\n".join([f"Q: {f['pregunta']}\nA: {f['respuesta']}" for f in faqs])

    prompt_template = PromptTemplate.from_template(

    
            
        Eres un asistente experto en atención al cliente.
        A partir de las siguientes FAQs, elegí las más relacionadas con la pregunta del usuario
        y generá una respuesta breve, útil y en tono amable.

        FAQs disponibles:
        {contexto}

        Pregunta del usuario:
        {pregunta}

        Responde de manera clara y directa:
        



    )

    chain = prompt_template | llm | StrOutputParser()
    respuesta = chain.invoke({"contexto": contexto, "pregunta": pregunta})
    return respuesta.strip()
"""
# ---------------------------------------------------------
# 🌐 Endpoints
# ---------------------------------------------------------
@app.get("/")
def root():
    return {"message": "API Chatbot FAQs con LangChain + Ollama local"}

@app.get("/preguntar")
def preguntar(pregunta: str = Query(..., min_length=3, description="Pregunta del usuario")):
    try:
        respuesta = responder_faqs(pregunta)
        return {
            "pregunta": pregunta,
            "respuesta": respuesta,
            "modelo": "llama3.2:3b",
            "status": "success"
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error inesperado: {str(e)}")
        raise HTTPException(status_code=500, detail="Error interno del servidor")

@app.get("/health")
def estado_conexiones():
    try:
        with get_db_connection() as db:
            db.ping(reconnect=True)
        return {"status": "healthy", "database": "connected"}
    except:
        return {"status": "unhealthy", "database": "disconnected"}
