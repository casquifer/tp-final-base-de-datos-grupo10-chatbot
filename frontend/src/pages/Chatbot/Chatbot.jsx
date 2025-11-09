import React, { useEffect, useState, useRef, useMemo } from "react";
import "./Chatbot.css";
import { sendChat } from "../../lib/api";

const STORAGE_KEY = "chat_consultas_rows";
const AUTOINC_KEY = "chat_autoinc";

export default function ChatBotPage() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [pending, setPending] = useState(false);
  const messagesEndRef = useRef(null);
  const userId = 1; // fijo

  // ======================
  // Helpers
  // ======================
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const readAll = () => {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
    } catch {
      return [];
    }
  };

  const writeAll = (rows) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(rows));
  };

  const nowStr = () => {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
  };

  const nextId = () => {
    const current = Number(localStorage.getItem(AUTOINC_KEY) || "1000") + 1;
    localStorage.setItem(AUTOINC_KEY, String(current));
    return current;
  };

  // ======================
  // Cargar mensajes al inicio
  // ======================
  useEffect(() => {
    const all = readAll();
    const userMsgs = all.filter((m) => m.id_usuario === userId);
    setMessages(userMsgs);
  }, []);

  // ======================
  // Scroll automático
  // ======================
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // ======================
  // Construye el historial
  // ======================
  const buildHistory = useMemo(
    () => (msgs) => {
      const mapped = msgs.map((m) => ({
        role: m.tipo === "bot" ? "assistant" : "user",
        content: m.texto,
      }));
      const MAX = 24; // últimas 12 interacciones (user+bot)
      return mapped.slice(-MAX);
    },
    []
  );

  // ======================
  // Enviar mensaje al backend
  // ======================
  const sendMessage = async (text) => {
    const trimmed = text.trim();
    if (!trimmed || pending) return;

    // Mensaje del usuario
    const userMsg = {
      id: nextId(),
      id_usuario: userId,
      fecha: nowStr(),
      texto: trimmed,
      tipo: "user",
    };

    const all = readAll();
    const newAll = [...all, userMsg];
    writeAll(newAll);
    setMessages((prev) => [...prev, userMsg]);
    setInput("");

    // Placeholder de “Escribiendo…”
    const typingMsg = {
      id: nextId(),
      id_usuario: userId,
      fecha: nowStr(),
      texto: "Escribiendo…",
      tipo: "bot",
      typing: true,
    };
    writeAll([...newAll, typingMsg]);
    setMessages((prev) => [...prev, typingMsg]);
    setPending(true);

    try {
      const history = buildHistory(newAll);
      const replyText = await sendChat({ userId, message: trimmed, history });

      const botMsg = {
        ...typingMsg,
        texto: replyText,
        typing: false,
      };

      const afterTyping = readAll().filter((m) => m.id !== typingMsg.id);
      writeAll([...afterTyping, botMsg]);
      setMessages((prev) =>
        prev.map((m) => (m.id === typingMsg.id ? botMsg : m))
      );
    } catch (err) {
      const errorMsg = {
        ...typingMsg,
        texto:
          "⚠️ Error al consultar el modelo.\n" +
          (err?.message ? `Detalle: ${err.message}` : ""),
        typing: false,
      };

      const afterTyping = readAll().filter((m) => m.id !== typingMsg.id);
      writeAll([...afterTyping, errorMsg]);
      setMessages((prev) =>
        prev.map((m) => (m.id === typingMsg.id ? errorMsg : m))
      );
    } finally {
      setPending(false);
    }
  };

  // ======================
  // Limpiar chat
  // ======================
  const clearChat = () => {
    if (pending) return;
    if (!confirm("¿Seguro que querés borrar todo el chat?")) return;

    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(AUTOINC_KEY);
    setMessages([]);
  };

  // ======================
  // Enviar con Enter
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
        <h2>Boticcelli</h2>
        <button
          className="btn clear"
          onClick={clearChat}
          title="Vaciar conversación"
          disabled={pending || messages.length === 0}
        >
          🗑 Vaciar chat
        </button>
      </div>

      <div className="chat-messages">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`message ${m.tipo === "bot" ? "bot" : "user"}`}
          >
            <div className="message-text">
              {m.texto?.split("\n").map((line, i) => (
                <span key={i}>
                  {line}
                  <br />
                </span>
              ))}
              {m.typing ? <span className="typing-dot">▌</span> : null}
            </div>
            <div className="message-time">{m.fecha}</div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div className="chat-input">
        <textarea
          rows="2"
          placeholder={pending ? "Consultando..." : "Escribí tu mensaje…"}
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKey}
          disabled={pending}
        />
        <button
          className="btn primary"
          onClick={() => sendMessage(input)}
          disabled={pending}
        >
          {pending ? "Enviando..." : "Enviar"}
        </button>
      </div>
    </div>
  );
}
