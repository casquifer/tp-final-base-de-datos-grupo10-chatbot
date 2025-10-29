import "../styles/BotonNavegacion.css"
import { useNavigate } from "react-router-dom";

// Componente reutilizable de formulario de autenticación
const BotonNavegacion = ({ 
  texto,
  boton,
  ruta
}) => {
    const navigate = useNavigate();

    return (
        <div className="auth-link">
            <p>{texto}</p>
            <button 
                className="auth-switch-button" 
                onClick={() => navigate(ruta)}
            >
                {boton}
            </button>
        </div>
    );
};

export default BotonNavegacion;