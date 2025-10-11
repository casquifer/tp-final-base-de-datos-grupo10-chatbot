import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Chatbot from './pages/Chatbot/Chatbot.jsx';
import Faq from './pages/Faq/Faq.jsx';
import { internalRoutes } from './service/routes/routes';

function App() {
  return (
    <Router>
      <Routes>
        <Route path={internalRoutes.chat} element={<Chatbot />} />
        <Route path={internalRoutes.faq} element={<Faq />} />
      </Routes>
    </Router>
  );
}

export default App;
