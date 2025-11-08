from fastapi import FastAPI, Query, HTTPException
from langchain_community.chat_models import ChatOllama
from langchain.prompts import PromptTemplate
from langchain.schema import StrOutputParser
import mysql.connector
import os
import time
import traceback

# ---------------------------------------------------------
# 🚀 Configuración general
# ---------------------------------------------------------
app = FastAPI(title="Chatbot - FAQs (Ollama Local)")

# Configuración de conexión a MySQL
MYSQL_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "mysql"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", "santi"),
    "database": os.getenv("MYSQL_DATABASE", "prueba")
}

# Configuración del modelo local de Ollama
llm = ChatOllama(
    base_url="http://ollama:11434",
    model="llama3.2:3b",
    temperature=0.3
)

# ---------------------------------------------------------
# 🔌 Conexión a la base de datos (COMPLETAMENTE CORREGIDA)
# ---------------------------------------------------------
def get_db_connection(retries=10, delay=3):
    """Obtiene una conexión a MySQL con reintentos"""
    last_error = None
    for i in range(retries):
        try:
            conn = mysql.connector.connect(**MYSQL_CONFIG)
            return conn
        except mysql.connector.Error as e:
            last_error = e
            if i < retries - 1:
                print(f"MySQL no listo, reintentando en {delay}s... ({i+1}/{retries})")
                time.sleep(delay)
    
    # Si llegamos aquí, todos los intentos fallaron
    raise HTTPException(
        status_code=503, 
        detail=f"No se pudo conectar a la base de datos después de {retries} intentos: {str(last_error)}"
    )

# ---------------------------------------------------------
# 🧩 Función principal: responder FAQs con contexto de la BBDD
# ---------------------------------------------------------
def responder_faqs(pregunta: str, usuario: str = "anonimo") -> str:
    conn = None
    try:
        # Obtener conexión
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
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

        # Extraer hechos conocidos del historial
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

        # Prompt
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
        print("Invocando modelo LLM...")
        chain = prompt_template | llm | StrOutputParser()
        respuesta = chain.invoke({"contexto_total": contexto_total, "pregunta": pregunta}).strip()
        print(f"Respuesta del modelo: {respuesta[:100]}...")

        # Guardar en logs con nueva conexión
        conn_log = get_db_connection()
        cursor_log = conn_log.cursor()
        cursor_log.execute(
            "INSERT INTO logs (usuario, entrada, salida) VALUES (%s, %s, %s)",
            (usuario, pregunta, respuesta)
        )
        conn_log.commit()
        cursor_log.close()
        conn_log.close()

        return respuesta
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error en responder_faqs: {str(e)}")
        print(f"Tipo: {type(e).__name__}")
        print(f"Traceback completo:\n{traceback.format_exc()}")
        raise
    finally:
        if conn and conn.is_connected():
            conn.close()

# ---------------------------------------------------------
# 🌐 Endpoints
# ---------------------------------------------------------
@app.get("/")
def root():
    return {"message": "API Chatbot FAQs con LangChain + Ollama local"}

@app.get("/preguntar")
def preguntar(pregunta: str = Query(..., min_length=3, description="Pregunta del usuario")):
    try:
        print(f"Recibida pregunta: {pregunta}")
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
        print(f"Error inesperado en endpoint: {str(e)}")
        print(f"Tipo: {type(e).__name__}")
        print(f"Traceback:\n{traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/health")
def estado_conexiones():
    try:
        conn = get_db_connection(retries=3, delay=1)
        conn.ping(reconnect=True)
        conn.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": "disconnected", "error": str(e)}