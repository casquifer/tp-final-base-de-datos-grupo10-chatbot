import React, { useEffect, useState, useRef } from "react";
import "./Chatbot.css";

const MOCK_KEY = "mock_consultas_rows";

export default function ChatBotPage() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const messagesEndRef = useRef(null);
  const userId = 1; // Siempre fijo, no se muestra en UI

  // ======================
  // Helpers
  // ======================
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const readAll = () => {
    try {
      return JSON.parse(localStorage.getItem(MOCK_KEY) || "[]");
    } catch {
      return [];
    }
  };

  const writeAll = (rows) => {
    localStorage.setItem(MOCK_KEY, JSON.stringify(rows));
  };

  const nowStr = () => {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
  };

  // =======================
  // Cargar mensajes al inicio
  // ======================
  useEffect(() => {
    const all = readAll();
    const userMsgs = all.filter((m) => m.id_usuario === userId);
    setMessages(userMsgs);
  }, []);

  // ======================
  // Scroll automático cada vez que cambian los mensajes
  // ======================
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // ======================
  // Enviar mensaje
  // ======================
  const sendMessage = (text) => {
    if (!text.trim()) return;

    // Crear ID automático
    const auto = Number(localStorage.getItem("mock_autoinc") || "1000") + 1;
    localStorage.setItem("mock_autoinc", String(auto));

    const userMsg = {
      id: auto,
      id_usuario: userId,
      fecha: nowStr(),
      texto: text,
      tipo: "user",
    };

    const all = readAll();
    all.push(userMsg);
    writeAll(all);
    setMessages((prev) => [...prev, userMsg]);
    setInput("");

    // Respuesta automática del bot
    setTimeout(() => {
      const botAutoId = Number(localStorage.getItem("mock_autoinc")) + 1;
      localStorage.setItem("mock_autoinc", String(botAutoId));

      const botMsg = {
        id: botAutoId,
        id_usuario: userId,
        fecha: nowStr(),
        texto: "¡Hola! ¿Todo Piola?",
        tipo: "bot",
      };

      const allUpdated = readAll();
      allUpdated.push(botMsg);
      writeAll(allUpdated);
      setMessages((prev) => [...prev, botMsg]);
    }, Math.random() * 3000 + 1500);
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
        <h2>CARPI</h2>
      </div>

      <div className="chat-messages">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`message ${m.tipo === "bot" ? "bot" : "user"}`}
          >
            <div className="message-text">{m.texto}</div>
            <div className="message-time">{m.fecha}</div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div className="chat-input">
        <textarea
          rows="2"
          placeholder="Escribí tu mensaje…"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKey}
        />
        <button className="btn primary" onClick={() => sendMessage(input)}>
          Enviar
        </button>
      </div>
    </div>
  );
}