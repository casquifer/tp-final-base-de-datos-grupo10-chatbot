const BASE_URL = import.meta.env.VITE_BACKEND_URL?.replace(/\/+$/, '') || '';

export async function sendChat({ userId, message, history = [] }) {
  const res = await fetch(`${BASE_URL}/api/chat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId, message, history }),
  });

  // El backend devuelve JSON siempre (200 OK o 500 con JSON de error)
  const data = await res.json().catch(() => null);

  if (!res.ok || !data?.ok) {
    const reason = data?.detail?.error || data?.error || `HTTP_${res.status}`;
    throw new Error(reason);
  }

  return data.reply; // texto de la respuesta del modelo
}
