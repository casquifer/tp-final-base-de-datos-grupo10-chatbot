import { useState } from "react";
import AuthForm from "../../components/AuthForm";
import axios from 'axios'
import { useNavigate } from "react-router-dom";
import '../../styles/login-registro.css';

const Registro = () => {
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const campos = [
    {
      name: 'name',
      type: 'text',
      label: 'Nombre completo',
      placeholder: 'Tu nombre',
      required: true
    },
    {
      name: 'email',
      type: 'email',
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
    },
    {
      name: 'confirmar',
      type: 'password',
      label: 'Confirmar contraseña',
      placeholder: 'Confirma tu contraseña',
      required: true
    }
  ];

  const handleRegister = async (formData) => {
    setError(null);
    try {
      if (!formData.name || !formData.email || !formData.password || !formData.confirmar) {
        throw new Error('Por favor, completa todos los campos.');
      }

      if (formData.password !== formData.confirmar) {
        throw new Error('Las contraseñas no coinciden.');
      }

      if (formData.password.length < 6) {
        throw new Error('La contraseña debe tener al menos 6 caracteres.');
      }

      const nuevoUsuario = {
        username: formData.name,
        password: formData.password
      }
      
      const resp = await axios.post('http://localhost:9000/registro/crear', nuevoUsuario)
      alert('¡Registro exitoso!');
      navigate('/login')
      
    } catch (err) {
      setError(err.message || 'Ocurrió un error. Inténtalo de nuevo.');
    }
  };

  return (
    
    <div className="login-page">
      <div className="login-hero">
        <h1 className="hero-title">Registrate a Botichelli</h1>
        <p className="hero-subtitle">Completa tus datos para realizar consultas personalizadas</p>
      </div>
      <div className="login-form-container">
        <AuthForm
          title="Crear cuenta"
          fields={campos}
          onSubmit={handleRegister}
          submitButtonText="Registrarse"
          error={error}
        />
      </div>
    </div>
  );
};

export default Registro;