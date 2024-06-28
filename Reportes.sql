--1. Consultar Pensum
DELIMITER //

CREATE PROCEDURE consultar_pensum (IN carrera_id INT)
BEGIN
    DECLARE carrera_count INT;

    -- Contar cuántas carreras existen con el ID proporcionado
    SELECT COUNT(*) INTO carrera_count
    FROM plan
    WHERE pla_id = carrera_id;

    -- Si no existe ninguna carrera con ese ID, lanzar un error
    IF carrera_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La carrera con el ID proporcionado no existe';
    ELSE
        -- Si la carrera existe, ejecutar la consulta
        SELECT
            pen_idCurso,
            pen_Nombre,
            pen_Obligatorio,
            pen_CreditosOtorgados,
            pen_CreditosNecesarios
        FROM
            pensum
        WHERE
            pen_Plan = carrera_id;
    END IF;
END //

DELIMITER ;

--2. Consultar estudiantes por carrera
DELIMITER //
CREATE PROCEDURE consultar_estudiante(IN carrera_id INT)
BEGIN
    DECLARE carrera_count INT;

    -- Contar cuántas carreras existen con el ID proporcionado
    SELECT COUNT(*) INTO carrera_count
    FROM carrera
    WHERE car_id = carrera_id;

    -- Si no existe ninguna carrera con ese ID, lanzar un error
    IF carrera_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La carrera con el ID proporcionado no existe';
    ELSE
        -- Si la carrera existe, ejecutar la consulta
        SELECT
            est_Carnet,
            CONCAT(est_Nombres, ' ', est_Apellidos) AS Nombre,
            car_Nombre AS Carrera
        FROM
            estudiantes
            JOIN carrera ON est_Carrera = car_id
        WHERE
            est_Carrera = carrera_id;
    END IF;
END //

DELIMITER ;


--3. Consultar docente con nombre concatenado
DELIMITER //

CREATE PROCEDURE consultar_docente(IN docente_id INT)
BEGIN
    DECLARE docente_count INT;

    -- Contar cuántos docentes existen con el ID proporcionado
    SELECT COUNT(*) INTO docente_count
    FROM docente
    WHERE doc_id = docente_id;

    -- Si no existe ningún docente con ese ID, lanzar un error
    IF docente_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El docente con el ID proporcionado no existe';
    ELSE
        -- Si el docente existe, ejecutar la consulta
        SELECT
            doc_id,
            CONCAT(doc_Nombres, ' ', doc_Apellidos) AS Nombre,
            doc_FechaNacimiento,
            doc_Correo,
            doc_Telefono,
            doc_Direccion,
            doc_Dpi
        FROM
            docente
        WHERE
            doc_id = docente_id;
    END IF;
END //

DELIMITER ;

--4. obtener asiganaciones
DELIMITER //

CREATE PROCEDURE consultar_asignaciones(
    IN curso_id INT, 
    IN ciclo VARCHAR(2), 
    IN seccion CHAR(1)
)
BEGIN
    DECLARE seccion_existe INT;
    
    -- Verificar si la sección existe en el ciclo y año
    SELECT COUNT(*) INTO seccion_existe
    FROM seccion s
    WHERE s.sec_ciclo = ciclo
      AND s.sec_seccion = seccion;
    
    -- Si no existe la sección, mostrar un mensaje de error
    IF seccion_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sección especificada no existe en el ciclo y año proporcionados';
    ELSE
        -- Obtener las asignaciones de estudiantes
        SELECT c.cur_carnet AS carnet, CONCAT(e.est_Nombres, ' ', e.est_Apellidos) AS Nombre
        FROM curso c
        JOIN seccion s ON c.cur_seccion = s.sec_id
        JOIN estudiantes e ON c.cur_carnet = e.est_Carnet
        WHERE c.cur_id = curso_id
          AND s.sec_ciclo = ciclo
          AND s.sec_seccion = seccion;
    END IF;
END //

DELIMITER ;

--5. obtener horario
DELIMITER //

CREATE PROCEDURE consultar_horario(
    IN estudiante_nombre VARCHAR(45),
    IN ciclo_seccion VARCHAR(2)
)
BEGIN
    DECLARE estudiante_existe INT;

    -- Verificar si el estudiante existe
    SELECT COUNT(*) INTO estudiante_existe
    FROM estudiantes
    WHERE est_Nombres = estudiante_nombre;

    -- Si el estudiante no existe, devolver un error
    IF estudiante_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre del estudiante no existe en la base de datos.';
    ELSE
        -- Consulta para obtener la información de los cursos
        SELECT
            p.pen_Nombre AS pen_nombre,
            s.sec_seccion AS sec_seccion,
            h.hor_dia AS hor_dia,
            h.hor_periodo AS hor_periodo,
            h.hor_salon AS hor_salon,
            per.horas AS periodo_horas
        FROM
            estudiantes e
            JOIN curso c ON e.est_Carnet = c.cur_carnet
            JOIN pensum p ON c.cur_id = p.pen_idCurso
            JOIN seccion s ON c.cur_seccion = s.sec_id
            JOIN horario h ON s.sec_id = h.hor_seccion
            JOIN periodo per ON h.hor_periodo = per.per_id
        WHERE
            e.est_Nombres = estudiante_nombre
            AND s.sec_ciclo = ciclo_seccion;
    END IF;
END //

DELIMITER ;

-- 6. Consultar aprobaciones
DELIMITER //

CREATE PROCEDURE consultar_aprobaciones(
    IN cur_id_param INT,
    IN sec_seccion_param CHAR(1)
)
BEGIN
    SELECT
        c.cur_id AS cur_id,
        c.cur_carnet AS carnet,
        CONCAT(e.est_Nombres, ' ', e.est_Apellidos) AS nombre,
        CASE
            WHEN c.nota > 61 THEN 'aprobado'
            ELSE 'reprobado'
        END AS aprobado
    FROM
        curso c
        JOIN estudiantes e ON c.cur_carnet = e.est_Carnet
        JOIN seccion s ON c.cur_seccion = s.sec_id
    WHERE
        c.cur_id = "5"
        AND s.sec_seccion = "H";
END //

DELIMITER ;

--8. insertar columna
-- -- Funcion para cantidades en letras 
DELIMITER $$
CREATE FUNCTION `number_to_words`(n INT) RETURNS varchar(100)
BEGIN
    -- This function returns the string representation of a number.
    -- It's just an example... I'll restrict it to hundreds, but
    -- it can be exdiezded easily.
    -- The idea is:
    --      For each digit you need a position,
    --      For each position, you assign a string
    declare ans varchar(100);
    declare dig1, dig2, dig3, dig4, dig5, dig6 int;

set ans = '';

set dig6 = CAST(RIGHT(CAST(floor(n / 100000) as CHAR(8)), 1) as SIGNED);
set dig5 = CAST(RIGHT(CAST(floor(n / 10000) as CHAR(8)), 1) as SIGNED);
set dig4 = CAST(RIGHT(CAST(floor(n / 1000) as CHAR(8)), 1) as SIGNED);
set dig3 = CAST(RIGHT(CAST(floor(n / 100) as CHAR(8)), 1) as SIGNED);
set dig2 = CAST(RIGHT(CAST(floor(n / 10) as CHAR(8)), 1) as SIGNED);
set dig1 = CAST(RIGHT(floor(n), 1) as SIGNED);

if dig6 > 0 then
    case
        when dig6=1 then set ans=concat(ans, 'uno cientos');
        when dig6=2 then set ans=concat(ans, 'dos cientos');
        when dig6=3 then set ans=concat(ans, 'tres cientos');
        when dig6=4 then set ans=concat(ans, 'cuatro cientos');
        when dig6=5 then set ans=concat(ans, 'cinco cientos');
        when dig6=6 then set ans=concat(ans, 'seis cientos');
        when dig6=7 then set ans=concat(ans, 'siete cientos');
        when dig6=8 then set ans=concat(ans, 'ocho cientos');
        when dig6=9 then set ans=concat(ans, 'nueve cientos');
        else set ans = ans;
    end case;
end if;

if dig5 = 1 then
    case
        when (dig5*10 + dig4) = 10 then set ans=concat(ans, ' diez mil ');
        when (dig5*10 + dig4) = 11 then set ans=concat(ans, ' once mil ');
        when (dig5*10 + dig4) = 12 then set ans=concat(ans, ' doce mil ');
        when (dig5*10 + dig4) = 13 then set ans=concat(ans, ' trece mil ');
        when (dig5*10 + dig4) = 14 then set ans=concat(ans, ' catorce mil ');
        when (dig5*10 + dig4) = 15 then set ans=concat(ans, ' quince mil ');
        when (dig5*10 + dig4) = 16 then set ans=concat(ans, ' dieciseis mil ');
        when (dig5*10 + dig4) = 17 then set ans=concat(ans, ' diecisiete mil ');
        when (dig5*10 + dig4) = 18 then set ans=concat(ans, ' dieciocho mil ');
        when (dig5*10 + dig4) = 19 then set ans=concat(ans, ' diecinueve mil ');
        else set ans=ans;
    end case;
else
    if dig5 > 0 then
        case
            when dig5=2 then set ans=concat(ans, ' veinte');
            when dig5=3 then set ans=concat(ans, ' treinta');
            when dig5=4 then set ans=concat(ans, ' cuarenta');
            when dig5=5 then set ans=concat(ans, ' cincuenta');
            when dig5=6 then set ans=concat(ans, ' sesenta');
            when dig5=7 then set ans=concat(ans, ' setenta');
            when dig5=8 then set ans=concat(ans, ' ochenta');
            when dig5=9 then set ans=concat(ans, ' noventa');
            else set ans=ans;
        end case;
    end if;
    if dig4 > 0 then
        case
            when dig4=1 then set ans=concat(ans, ' uno mil ');
            when dig4=2 then set ans=concat(ans, ' dos mil ');
            when dig4=3 then set ans=concat(ans, ' tres mil ');
            when dig4=4 then set ans=concat(ans, ' cuatro mil ');
            when dig4=5 then set ans=concat(ans, ' cinco mil ');
            when dig4=6 then set ans=concat(ans, ' seis mil ');
            when dig4=7 then set ans=concat(ans, ' siete mil ');
            when dig4=8 then set ans=concat(ans, ' ocho mil ');
            when dig4=9 then set ans=concat(ans, ' nueve mil ');
            else set ans=ans;
        end case;
    end if;
    if dig4 = 0 AND (dig5 != 0 || dig6 != 0) then
        set ans=concat(ans, ' mil ');
    end if;
end if;

if dig3 > 0 then
    case
        when dig3=1 then set ans=concat(ans, 'ciento');
        when dig3=2 then set ans=concat(ans, 'dos cientos');
        when dig3=3 then set ans=concat(ans, 'tres cientos');
        when dig3=4 then set ans=concat(ans, 'cuatro cientos');
        when dig3=5 then set ans=concat(ans, 'cinco cientos');
        when dig3=6 then set ans=concat(ans, 'seis cientos');
        when dig3=7 then set ans=concat(ans, 'siete cientos');
        when dig3=8 then set ans=concat(ans, 'ocho cientos');
        when dig3=9 then set ans=concat(ans, 'nueve cientos');
        else set ans = ans;
    end case;
end if;

if dig2 = 1 then
    case
        when (dig2*10 + dig1) = 10 then set ans=concat(ans, ' diez');
        when (dig2*10 + dig1) = 11 then set ans=concat(ans, ' once');
        when (dig2*10 + dig1) = 12 then set ans=concat(ans, ' doce');
        when (dig2*10 + dig1) = 13 then set ans=concat(ans, ' trece');
        when (dig2*10 + dig1) = 14 then set ans=concat(ans, ' catorce');
        when (dig2*10 + dig1) = 15 then set ans=concat(ans, ' quince');
        when (dig2*10 + dig1) = 16 then set ans=concat(ans, ' dieciseis');
        when (dig2*10 + dig1) = 17 then set ans=concat(ans, ' diecisiete');
        when (dig2*10 + dig1) = 18 then set ans=concat(ans, ' dieciocho');
        when (dig2*10 + dig1) = 19 then set ans=concat(ans, ' diecinueve');
        else set ans=ans;
    end case;
else
    if dig2 > 0 then
        case
            when dig2=2 then set ans=concat(ans, ' veinte y');
            when dig2=3 then set ans=concat(ans, ' treinta y');
            when dig2=4 then set ans=concat(ans, ' cuarenta y');
            when dig2=5 then set ans=concat(ans, ' cincuenta y');
            when dig2=6 then set ans=concat(ans, ' sesenta y');
            when dig2=7 then set ans=concat(ans, ' setenta y');
            when dig2=8 then set ans=concat(ans, ' ochenta y');
            when dig2=9 then set ans=concat(ans, ' noventa y');
            else set ans=ans;
        end case;
    end if;
    if dig1 > 0 then
        case
            when dig1=1 then set ans=concat(ans, ' uno');
            when dig1=2 then set ans=concat(ans, ' dos');
            when dig1=3 then set ans=concat(ans, ' tres');
            when dig1=4 then set ans=concat(ans, ' cuatro');
            when dig1=5 then set ans=concat(ans, ' cinco');
            when dig1=6 then set ans=concat(ans, ' seis');
            when dig1=7 then set ans=concat(ans, ' siete');
            when dig1=8 then set ans=concat(ans, ' ocho');
            when dig1=9 then set ans=concat(ans, ' nueve');
            else set ans=ans;
        end case;
    end if;
end if;

return trim(ans);
END
$$
DELIMITER ;

---- docente
DELIMITER //

CREATE PROCEDURE insertar_columna()
BEGIN

SELECT
    d.doc_id AS doc_id,
    d.doc_Nombres AS doc_Nombres,
    d.doc_Apellidos AS doc_Apellidos,
    d.doc_FechaNacimiento AS doc_FechaNacimiento,
    d.doc_Correo AS doc_Correo,
    d.doc_Telefono AS doc_Telefono,
    d.doc_Direccion AS doc_Direccion,
    d.doc_Dpi AS doc_Dpi,
    d.doc_Salario AS doc_Salario,
    number_to_words(d.doc_Salario) AS salario_en_letras
FROM
    docente d;

END // 
DELIMITER ;

-- REGISTRO -----------------------------------
--creamos tabla transacciones 
CREATE TABLE transacciones (
  id INT NOT NULL AUTO_INCREMENT,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tabla VARCHAR(50) NOT NULL,
  operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  PRIMARY KEY (id)
);
-- Trigger para la tabla Carrera
DELIMITER //

CREATE TRIGGER tr_carrera_ins
AFTER INSERT ON carrera
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('carrera', 'INSERT');
END//

CREATE TRIGGER tr_carrera_upd
AFTER UPDATE ON carrera
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('carrera', 'UPDATE');
END//

CREATE TRIGGER tr_carrera_del
AFTER DELETE ON carrera
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('carrera', 'DELETE');
END//

DELIMITER ;
-- Trigger para la tabla estudiantes
DELIMITER //

CREATE TRIGGER tr_estudiantes_ins
AFTER INSERT ON estudiantes
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('estudiantes', 'INSERT');
END//

CREATE TRIGGER tr_estudiantes_upd
AFTER UPDATE ON estudiantes
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('estudiantes', 'UPDATE');
END//

CREATE TRIGGER tr_estudiantes_del
AFTER DELETE ON estudiantes
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('estudiantes', 'DELETE');
END//
-- Trigger para la tabla docente
DELIMITER //

CREATE TRIGGER tr_docente_ins
AFTER INSERT ON docente
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('docente', 'INSERT');
END//

CREATE TRIGGER tr_docente_upd
AFTER UPDATE ON docente
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('docente', 'UPDATE');
END//

CREATE TRIGGER tr_docente_del
AFTER DELETE ON docente
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('docente', 'DELETE');
END//
-- Trigger para la tabla pensum
DELIMITER //

CREATE TRIGGER tr_pensum_ins
AFTER INSERT ON pensum
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('pensum', 'INSERT');
END//

CREATE TRIGGER tr_pensum_upd
AFTER UPDATE ON pensum
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('pensum', 'UPDATE');
END//

CREATE TRIGGER tr_pensum_del
AFTER DELETE ON pensum
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('pensum', 'DELETE');
END//

DELIMITER ;
-- Trigger para la tabla curso
DELIMITER //

CREATE TRIGGER tr_curso_ins
AFTER INSERT ON curso
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('curso', 'INSERT');
END//

CREATE TRIGGER tr_curso_upd
AFTER UPDATE ON curso
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('curso', 'UPDATE');
END//

CREATE TRIGGER tr_curso_del
AFTER DELETE ON curso
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('curso', 'DELETE');
END//

DELIMITER ;
-- Trigger para la tabla seccion
DELIMITER //

CREATE TRIGGER tr_seccion_ins
AFTER INSERT ON seccion
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('seccion', 'INSERT');
END//

CREATE TRIGGER tr_seccion_upd
AFTER UPDATE ON seccion
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('seccion', 'UPDATE');
END//

CREATE TRIGGER tr_seccion_del
AFTER DELETE ON seccion
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('seccion', 'DELETE');
END//

DELIMITER ;
-- Trigger para la tabla horario
DELIMITER //

CREATE TRIGGER tr_horario_ins
AFTER INSERT ON horario
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('horario', 'INSERT');
END//

CREATE TRIGGER tr_horario_upd
AFTER UPDATE ON horario
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('horario', 'UPDATE');
END//

CREATE TRIGGER tr_horario_del
AFTER DELETE ON horario
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('horario', 'DELETE');
END//

DELIMITER ;
-- Trigger para la tabla prerrequisito
DELIMITER //

CREATE TRIGGER tr_prerrequisito_ins
AFTER INSERT ON prerrequisito
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('prerrequisito', 'INSERT');
END//

CREATE TRIGGER tr_prerrequisito_upd
AFTER UPDATE ON prerrequisito
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('prerrequisito', 'UPDATE');
END//

CREATE TRIGGER tr_prerrequisito_del
AFTER DELETE ON prerrequisito
FOR EACH ROW
BEGIN
  INSERT INTO transacciones (tabla, operacion)
  VALUES ('prerrequisito', 'DELETE');
END//

DELIMITER ;


