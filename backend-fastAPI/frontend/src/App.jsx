import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Chatbot from './pages/Chatbot/Chatbot.jsx';
import Faq from './pages/Faq/Faq.jsx';
import Login from './pages/Login/Login.jsx';
import Registro from "./pages/Registro/Registro.jsx"
import { internalRoutes } from './service/routes/routes';

function App() {
  return (
    <Router>
      <Routes>
        <Route path={internalRoutes.chat} element={<Chatbot />} />
        <Route path={internalRoutes.faq} element={<Faq />} />
        <Route path={internalRoutes.login} element={<Login />} />
        <Route path={internalRoutes.registro} element={<Registro />} />
      </Routes>
    </Router>
  );
}

export default App;
