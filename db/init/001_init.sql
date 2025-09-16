CREATE TABLE IF NOT EXISTS alumnos (id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(100), email VARCHAR(100));
CREATE TABLE IF NOT EXISTS periodos (id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(100), fecha_inicio DATE, fecha_fin DATE);
CREATE VIEW IF NOT EXISTS vista_postulaciones AS
  SELECT 1 AS alumno_id, 1 AS periodo_id, 'activa' AS estado, DATE('2025-01-01') AS fecha_inicio, DATE('2025-01-31') AS fecha_fin;
