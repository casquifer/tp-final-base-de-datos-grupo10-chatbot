import React, { useEffect, useState, useRef } from "react";
import axios from "axios";
import "./Chatbot.css";

const BACKEND_URL = "http://localhost:8000";

export default function ChatBotPage() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);
  
  // Obtener username del localStorage (del login)
  const username = localStorage.getItem('username') || 'anonimo';

  // ======================
  // Helpers
  // ======================
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const nowStr = () => {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
  };

  // ======================
  // Scroll automático
  // ======================
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // ======================
  // Enviar mensaje al backend
  // ======================
  const sendMessage = async (text) => {
    if (!text.trim() || isLoading) return;

    // Agregar mensaje del usuario a la UI
    const userMsg = {
      id: Date.now(),
      texto: text,
      tipo: "user",
      fecha: nowStr(),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setIsLoading(true);

    try {
      // Llamar al backend
      const response = await axios.get(`${BACKEND_URL}/preguntar`, {
        params: {
          pregunta: text,
          usuario: username  // Opcional: si quieres pasar el usuario
        }
      });

      // Agregar respuesta del bot
      const botMsg = {
        id: Date.now() + 1,
        texto: response.data.respuesta,
        tipo: "bot",
        fecha: nowStr(),
      };

      setMessages((prev) => [...prev, botMsg]);
    } catch (error) {
      console.error("Error al enviar mensaje:", error);
      
      // Mensaje de error
      const errorMsg = {
        id: Date.now() + 1,
        texto: "Lo siento, hubo un error al procesar tu mensaje. Por favor, intentá de nuevo.",
        tipo: "bot",
        fecha: nowStr(),
      };

      setMessages((prev) => [...prev, errorMsg]);
    } finally {
      setIsLoading(false);
    }
  };

  // ======================
  // Enviar mensaje con Enter
  // ======================
  const handleKey = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage(input);
    }
  };

  // ======================
  // Render
  // ======================
  return (
    <div className="chat-container">
      <div className="chat-header">
        <h2>Botichelli</h2>
        <span className="username-badge">{username}</span>
      </div>

      <div className="chat-messages">
        {messages.length === 0 && (
          <div className="welcome-message">
            <p>👋 ¡Hola! Soy Botichelli, tu asistente virtual.</p>
            <p>¿En qué puedo ayudarte hoy?</p>
          </div>
        )}

        {messages.map((m) => (
          <div
            key={m.id}
            className={`message ${m.tipo === "bot" ? "bot" : "user"}`}
          >
            <div className="message-text">{m.texto}</div>
            <div className="message-time">{m.fecha}</div>
          </div>
        ))}

        {isLoading && (
          <div className="message bot">
            <div className="message-text">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      <div className="chat-input">
        <textarea
          rows="2"
          placeholder="Escribí tu mensaje…"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKey}
          disabled={isLoading}
        />
        <button 
          className="btn primary" 
          onClick={() => sendMessage(input)}
          disabled={isLoading || !input.trim()}
        >
          {isLoading ? "Enviando..." : "Enviar"}
        </button>
      </div>
    </div>
  );
}