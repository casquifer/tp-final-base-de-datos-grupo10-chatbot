import { useState } from "react";
import AuthForm from "../../components/AuthForm";

const Registro = () => {
  const [error, setError] = useState(null);

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

      console.log('Registro simulado:', {
        name: formData.name,
        email: formData.email,
        password: formData.password
      });
      
      alert('¡Registro exitoso!');
    } catch (err) {
      setError(err.message || 'Ocurrió un error. Inténtalo de nuevo.');
    }
  };

  return (
    <AuthForm
      title="Crear cuenta"
      fields={campos}
      onSubmit={handleRegister}
      submitButtonText="Registrarse"
      error={error}
    />
  );
};

export default Registro;