import { useState } from 'react';
import "../styles/form-datos.css";
import BotonNavegacion from './BotonNavegacion';

const AuthForm = ({ 
  title, 
  fields, 
  onSubmit, 
  submitButtonText,
  error 
}) => {
  const [formData, setFormData] = useState(
    fields.reduce((acc, field) => ({ ...acc, [field.name]: '' }), {})
  );
  const [showPasswords, setShowPasswords] = useState({});

  const handleChange = (name, value) => {
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const togglePasswordVisibility = (name) => {
    setShowPasswords(prev => ({ ...prev, [name]: !prev[name] }));
  };

  const handleSubmit = () => {
    onSubmit(formData);
  };

  const handleKeyDown = (event) => {
    if (event.key === 'Enter') handleSubmit();
  };

  return (
    <div className="login-container">
      <div className="login-content">
        <h1 className="login-title">{title}</h1>
        <div className="login-form" onKeyDown={handleKeyDown}>
          {fields.map(field => (
            <label key={field.name} className={field.type === 'password' ? 'password-label' : ''}>
              {field.label}{field.required && '*'}
              <input
                type={field.type === 'password' && showPasswords[field.name] ? 'text' : field.type}
                placeholder={field.placeholder}
                className="login-input"
                value={formData[field.name]}
                onChange={(e) => handleChange(field.name, e.target.value)}
              />
              {field.type === 'password' && (
                <span
                  className="toggle-password"
                  onClick={() => togglePasswordVisibility(field.name)}
                >
                  {showPasswords[field.name] ? '🙈' : '👁️'}
                </span>
              )}
            </label>
          ))}
          <button className="login-button" onClick={handleSubmit}>
            {submitButtonText}
          </button>
        </div>
        {error && (
          <div className="login-error-container">
            <p className="login-error-message">{error}</p>
          </div>
        )}
        {title=='Iniciar sesión' ? 
        <BotonNavegacion 
          texto={'No tenés cuenta?'}
          boton={'Crear cuenta'}
          ruta={'/registro'}
        />
        :
        <BotonNavegacion 
          texto={'¿Ya tenés cuenta?'}
          boton={'Iniciar sesión'}
          ruta={'/login'}
        />
      }
      </div>
    </div>
  );
};

export default AuthForm;