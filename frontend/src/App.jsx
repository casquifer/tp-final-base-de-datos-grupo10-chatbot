import React from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login/Login.jsx'
import Registro from './pages/Registro/Registro.jsx'
import Chatbot from './pages/Chatbot/Chatbot.jsx'
import Faq from './pages/Faq/Faq.jsx'
import { internalRoutes } from './service/routes/routes'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to={internalRoutes.login} replace />} />
        <Route path={internalRoutes.login} element={<Login />} />
        <Route path={internalRoutes.registro} element={<Registro />} />
        <Route path={internalRoutes.chat} element={<Chatbot />} />
        <Route path={internalRoutes.faq} element={<Faq />} />
        {/* Opcional: 404 */}
        <Route path="*" element={<Navigate to={internalRoutes.login} replace />} />
      </Routes>
    </Router>
  )
}

export default App
