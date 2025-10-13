from fastapi import FastAPI, Query, HTTPException
import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.schema import StrOutputParser
import mysql.connector
from contextlib import contextmanager
import os
import time

app = FastAPI(title="Chatbot - FAQs")

# configuracion de mysql
MYSQL_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "mysql"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", "santi"),
    "database": os.getenv("MYSQL_DATABASE", "prueba")
}

# configuracion de llm - Gemini
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)

llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=GEMINI_API_KEY,
    temperature=0.3
)

# conexion a la BBDD
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

# funcion principal - toma pregunta -> IA procesa pregunta + BBDD + prompt -> devuelve respuesta
def responder_faqs(pregunta: str) -> str:
    with get_db_connection() as db:
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT pregunta, respuesta FROM FAQs")
        faqs = cursor.fetchall()
        cursor.close()

    if not faqs:
        return "No encontré información relevante en las FAQs."

    contexto = "\n\n".join([f"Q: {f['pregunta']}\nA: {f['respuesta']}" for f in faqs])

    prompt_template = PromptTemplate.from_template(
        """
        Eres un asistente experto en atención al cliente.
        A partir de las siguientes FAQs, elige las más relacionadas con la pregunta del usuario y genera una respuesta útil y breve.
        
        FAQs disponibles:
        {contexto}

        Pregunta del usuario:
        {pregunta}

        Responde en tono amable y claro:
        """
    )

    chain = prompt_template | llm | StrOutputParser()
    respuesta = chain.invoke({"contexto": contexto, "pregunta": pregunta})
    return respuesta.strip()

# endpoints
@app.get("/")
def root():
    return {"message": "API Chatbot FAQs con LangChain y Gemini"}

@app.get("/preguntar")
def preguntar(pregunta: str = Query(..., min_length=3, description="Pregunta del usuario")):
    try:
        respuesta = responder_faqs(pregunta)
        return {
            "pregunta": pregunta,
            "respuesta": respuesta,
            "modelo": "gemini-2.5-flash",
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
