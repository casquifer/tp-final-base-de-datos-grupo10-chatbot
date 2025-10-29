import { useState } from 'react';
import './Login.css';
import { useNavigate } from 'react-router-dom';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleLogin = async () => {
    setError(null);
    try {
      if (!email || !password) {
        throw new Error('Por favor, completa todos los campos.');
      }
      console.log('Inicio de sesión simulado:', { email, password });
      navigate('/');
    } catch (err) {
      if (err.response && err.response.status === 401) {
        setError('Usuario no autorizado. Verificá tus credenciales.');
      } else {
        setError(err.message || 'Ocurrió un error. Inténtalo de nuevo.');
      }
    }
  };

  const handleKeyDown = (event) => {
    if (event.key === 'Enter') handleLogin();
  };

  return (
    <div className="login-container">
      <div className="login-content">
        <h1 className="login-title">Iniciar sesión</h1>
        <div className="login-form" onKeyDown={handleKeyDown}>
          <label>
            Email*
            <input
              type="email"
              placeholder="Correo electrónico"
              className="login-input"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </label>

          <label className="password-label">
            Contraseña
            <input
              type={showPassword ? 'text' : 'password'}
              placeholder="Contraseña"
              className="login-input"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <span
              className="toggle-password"
              onClick={() => setShowPassword(prev => !prev)}
            >
              {showPassword ? '🙈' : '👁️'}
            </span>
          </label>

          <button className="login-button" onClick={handleLogin}>
            Iniciar sesión
          </button>
        </div>

        {error && (
          <div className="login-error-container">
            <p className="login-error-message">{error}</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Login;
