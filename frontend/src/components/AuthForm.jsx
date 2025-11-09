import { useState } from 'react';
import "../styles/form-datos.css";
import BotonNavegacion from './BotonNavegacion';

const AuthForm = ({ 
  titulo, 
  campos, 
  onSubmit, 
  submitButtonText,
  error 
}) => {
  const [formData, setFormData] = useState(
    campos.reduce((acc, field) => ({ ...acc, [field.name]: '' }), {})
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
    <div className="form-container">
      <div className="form-content">
        <h1 className="form-titulo">{titulo}</h1>
        <div className="form" onKeyDown={handleKeyDown}>
          {campos.map(field => (
            <label key={field.name} className={field.type === 'password' ? 'password-label' : ''}>
              {field.label}{field.required && '*'}
              <input
                type={field.type === 'password' && showPasswords[field.name] ? 'text' : field.type}
                placeholder={field.placeholder}
                className="form-input"
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
          <button className="form-button" onClick={handleSubmit}>
            {submitButtonText}
          </button>
        </div>
        {error && (
          <div className="form-error">
            <p className="form-error-mensaje">{error}</p>
          </div>
        )}
        {titulo=='Iniciar sesión' ? 
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