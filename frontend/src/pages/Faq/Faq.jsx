import React, { useState } from "react";
import "./Faq.css";
import { FAQs } from "../../mocks/faqsMock";


export default function FAQPage({ onSelect }) {
  const [search, setSearch] = useState("");
  const [openIds, setOpenIds] = useState([]);

  const toggle = (id) => {
    setOpenIds(openIds.includes(id) ? openIds.filter(x => x !== id) : [...openIds, id]);
  };

  const filtered = FAQs.filter(faq =>
    faq.pregunta.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="faq-container">
      <h2>Preguntas Frecuentes</h2>

      <input
        type="text"
        placeholder="Buscar..."
        value={search}
        onChange={e => setSearch(e.target.value)}
        className="faq-search"
      />

      <div className="faq-list">
        {filtered.map(faq => (
          <div key={faq.id} className="faq-item">
            <div className="faq-question" onClick={() => toggle(faq.id)}>
              {faq.pregunta}
            </div>
            {openIds.includes(faq.id) && (
              <div className="faq-answer">
                {faq.respuesta}
                {onSelect && (
                  <button className="btn small" onClick={() => onSelect(faq.pregunta)}>
                    Enviar al chat
                  </button>
                )}
              </div>
            )}
          </div>
        ))}
        {filtered.length === 0 && <p>No se encontraron resultados.</p>}
      </div>
    </div>
  );
}
