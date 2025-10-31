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
      <div className="login-intro">
        <h1 className="intro-title">Bienvenido a Botichelli</h1>
        <p className="intro-subtitle">Accede con tu cuenta para realizar consultas</p>
      </div>
      <div className="login-form-container">
        <AuthForm
          titulo="Iniciar sesión"
          campos={loginFields}
          onSubmit={handleLogin}
          submitButtonText="Iniciar sesión"
          error={error}
        />
      </div>
    </div>
  );
};

export default Login;
