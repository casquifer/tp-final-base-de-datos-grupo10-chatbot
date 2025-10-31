import { useState } from "react";
import AuthForm from "../../components/AuthForm";
import axios from 'axios';
import { useNavigate } from "react-router-dom";
import '../../styles/login-registro.css';

const Login = () => {
  const [error, setError] = useState(null);
  
  const loginFields = [
    {
      name: 'username',
      type: 'username',
      label: 'Email',
      placeholder: 'Correo electrónico',
      required: true
    },
    {
      name: 'password',
      type: 'password',
      label: 'Contraseña',
      placeholder: 'Contraseña',
      required: true
    }
  ];

  const navigate = useNavigate();

  const handleLogin = async (formData) => {
    setError(null);
    try {
      if (!formData.username || !formData.password) {
        throw new Error('Por favor, completa todos los campos.');
      }

      console.log('Inicio de sesión simulado:', formData);
      const resp = await axios.post('http://localhost:9000/login', formData)
      if(resp.data.ok){
        navigate('/Chatbot')
      } else{
        throw new Error('El usuario o la contraseña es incorrecto')
      }
    } catch (err) {
      if (err.response && err.response.status === 401) {
        setError('Usuario no autorizado. Verificá tus credenciales.');
      } else {
        setError(err.message || 'Ocurrió un error. Inténtalo de nuevo.');
      }
    }
  };

  return (
    <div className="login-page">
      <div className="login-hero">
        <h1 className="hero-title">Bienvenido a Botichelli</h1>
        <p className="hero-subtitle">Accede con tu cuenta para realizar consultas</p>
      </div>
      <div className="login-form-container">
        <AuthForm
          title="Iniciar sesión"
          fields={loginFields}
          onSubmit={handleLogin}
          submitButtonText="Iniciar sesión"
          error={error}
        />
      </div>
    </div>
  );
};

export default Login;
