CREATE DATABASE  IF NOT EXISTS `prueba`;
USE `prueba`;

-- Crear la tabla plan
CREATE TABLE plan (
  pla_id INT NOT NULL AUTO_INCREMENT,
  pla_plan VARCHAR(15) NOT NULL,
  PRIMARY KEY (pla_id)
);

DELIMITER //

CREATE TRIGGER vali_plan
BEFORE INSERT ON plan
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);

    -- Validar que el ciclo sea uno de los valores dados
    IF NEW.pla_plan NOT IN ('matutina', 'vespertina', 'Matutina', 'Vespertina') THEN
        SET error_msg = 'El campo de plan no es de los valores aceptados.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

END //

DELIMITER ;

--pruebas
--valida
INSERT INTO plan (pla_plan) VALUES ('Matutina');
INSERT INTO plan (pla_plan) VALUES ('Vespertina');

--invalida
INSERT INTO plan (pla_plan) VALUES ('MatutinAS');

-- Crear la tabla carrera
CREATE TABLE carrera (
  car_id INT NOT NULL AUTO_INCREMENT,
  car_Nombre VARCHAR(45) COLLATE armscii8_bin DEFAULT NULL,
  PRIMARY KEY (car_id),
  UNIQUE KEY Nombre_UNIQUE (car_Nombre)
);

DELIMITER //

CREATE TRIGGER vali_nom_carrera
BEFORE INSERT ON carrera
FOR EACH ROW
BEGIN
  -- Verifica si el nombre contiene solo letras y espacios
  IF NOT NEW.car_Nombre REGEXP '^[a-zA-Z\s]+$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo nombre debe contener solo letras.';
  END IF;
  
  -- Verifica si el nombre de la carrera ya existe
  IF (SELECT COUNT(*) FROM carrera WHERE car_Nombre = NEW.car_Nombre) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la carrera ya existe.';
  END IF;
END;
//

DELIMITER ;

-- Insertar sin error en carrera
INSERT INTO carrera (car_Nombre) VALUES ('Ingenieria');

-- Insertar con error en carrera
INSERT INTO carrera (car_Nombre) VALUES ('Ingenieria123');
INSERT INTO carrera (car_Nombre) VALUES ('Licenciatura!');

-- Insertar con error en carrera porque ya existe 
INSERT INTO carrera (car_Nombre) VALUES ('Ingenieria');

-- Insertar sin error en carrera
INSERT INTO carrera (car_Nombre) VALUES ('Agronomia');

-- Eliminar tabla
DROP TABLE carrera;
DROP TABLE estudiantes;
DROP TABLE docente;
DROP TABLE pensum;

-- Ver todo el contenido de la tabla
SELECT * FROM carrera;


-- Crear la tabla estudiantes
CREATE TABLE `estudiantes` (
  `est_Carnet` int NOT NULL,
  `est_Nombres` varchar(45) NOT NULL,
  `est_Apellidos` varchar(45) NOT NULL,
  `est_FechaNacimiento` date NOT NULL,
  `est_Correo` varchar(45) NOT NULL,
  `est_Telefono` int NOT NULL,
  `est_Direccion` varchar(45) NOT NULL,
  `est_Dpi` BIGINT NOT NULL,
  `est_FechaRegistro` date NOT NULL,
  `est_Carrera` int NOT NULL,
  `est_Plan` int NOT NULL,
  PRIMARY KEY (`est_Carnet`),
  KEY `idCarrer_idx` (`est_Carrera`),
  CONSTRAINT `idCarrer` FOREIGN KEY (`est_Carrera`) REFERENCES `carrera` (`car_id`),
  CONSTRAINT `idPlan` FOREIGN KEY (`est_Plan`) REFERENCES `plan` (`pla_id`)
);

DELIMITER //

CREATE TRIGGER vali_estudiantes
BEFORE INSERT ON estudiantes
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);
    DECLARE v_valid_carrera INT;
    DECLARE v_valid_plan INT;

    -- Validar que los nombres solo contengan letras y espacios
    IF NEW.est_Nombres NOT REGEXP '^[a-zA-Z\s]+$' THEN
        SET error_msg = 'El campo nombre debe contener solo letras.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que los apellidos solo contengan letras y espacios
    IF NEW.est_Apellidos NOT REGEXP '^[a-zA-Z\s]+$' THEN
        SET error_msg = 'El campo apellido debe contener solo letras.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar el formato del correo
    IF NEW.est_Correo NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' THEN
        SET error_msg = 'Formato de correo inválido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

     -- Validar que el teléfono no contenga el código de área
    IF NEW.est_Telefono NOT REGEXP '^[0-9]+$' THEN
        SET error_msg = 'El teléfono debe obviar el codigo de area.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar existencia de la carrera
    SELECT COUNT(*) INTO v_valid_carrera FROM carrera WHERE car_id = NEW.est_Carrera;
    IF v_valid_carrera = 0 THEN
        SET error_msg = 'La carrera no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar existencia del plan
    SELECT COUNT(*) INTO v_valid_plan FROM plan WHERE pla_id = NEW.est_Plan;
    IF v_valid_plan = 0 THEN
        SET error_msg = 'El plan no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;
END //

DELIMITER ;


-- Insertar un estudiante con datos válidos
INSERT INTO estudiantes (est_Carnet, est_Nombres, est_Apellidos, est_FechaNacimiento, est_Correo, est_Telefono, est_Direccion, est_Dpi, est_FechaRegistro, est_Carrera, est_Plan)
VALUES (1, 'Nataly', 'Guzman', '2000-06-10', 'natalyguzman7777@gmail.com', 40615221, 'Zona 7 Guatemala', 121412518129, '2020-01-01', 1, 1);

-- Insertar un estudiante con datos inválidos
INSERT INTO estudiantes (est_Carnet, est_Nombres, est_Apellidos, est_FechaNacimiento, est_Correo, est_Telefono, est_Direccion, est_Dpi, est_FechaRegistro, est_Carrera, est_Plan)
VALUES (2, 'Nataly121', 'Guzman', '2000-06-10', 'natalyguzman7777@gmail.com', 40615221, 'Zona 7 Guatemala', 121412518129, '2020-01-01', 1, 1);

-- Insertar un estudiante con datos inválidos
INSERT INTO estudiantes (est_Carnet, est_Nombres, est_Apellidos, est_FechaNacimiento, est_Correo, est_Telefono, est_Direccion, est_Dpi, est_FechaRegistro, est_Carrera, est_Plan)
VALUES (2, 'Nataly', 'Guzman121', '2000-06-10', 'natalyguzman7777@gmail.com', 40615221, 'Zona 7 Guatemala', 121412518129, '2020-01-01', 1, 1);

-- Insertar un estudiante con datos inválidos
INSERT INTO estudiantes (est_Carnet, est_Nombres, est_Apellidos, est_FechaNacimiento, est_Correo, est_Telefono, est_Direccion, est_Dpi, est_FechaRegistro, est_Carrera, est_Plan)
VALUES (2, 'Nataly', 'Guzman', '2000-06-10', 'natalyguzman7777@', 40615221, 'Zona 7 Guatemala', 121412518129, '2020-01-01', 1, 1);

-- Insertar un estudiante con datos inválidos
INSERT INTO estudiantes (est_Carnet, est_Nombres, est_Apellidos, est_FechaNacimiento, est_Correo, est_Telefono, est_Direccion, est_Dpi, est_FechaRegistro, est_Carrera, est_Plan)
VALUES (3, 'Nataly', 'Guzman', '2000-06-10', 'natalyguzman7777@', "+50240615221", 'Zona 7 Guatemala', 121412518129, '2020-01-01', 1, 1);

-- Crear la tabla estudiantes
CREATE TABLE `docente` (
  `doc_id` int NOT NULL,
  `doc_Nombres` varchar(45) NOT NULL,
  `doc_Apellidos` varchar(45) NOT NULL,
  `doc_FechaNacimiento` date NOT NULL,
  `doc_Correo` varchar(45) NOT NULL,
  `doc_Telefono` int NOT NULL,
  `doc_Direccion` varchar(45) NOT NULL,
  `doc_Dpi` BIGINT NOT NULL,
  `doc_Salario` float NOT NULL,
  `doc_FechaRegistro` date NOT NULL,
  PRIMARY KEY (`doc_id`)
);

DELIMITER //

CREATE TRIGGER vali_docente
BEFORE INSERT ON docente
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);  -- Declarar la variable error_msg
    DECLARE v_count INT;

    -- Validar que el doc_id no exista
    SELECT COUNT(*) INTO v_count FROM docente WHERE doc_id = NEW.doc_id;
    IF v_count > 0 THEN
        SET error_msg = 'El ID del docente ya existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que los nombres solo contengan letras y espacios
    IF NEW.doc_Nombres NOT REGEXP '^[a-zA-Z\s]+$' THEN
        SET error_msg = 'El campo nombre debe contener solo letras.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que los apellidos solo contengan letras y espacios
    IF NEW.doc_Apellidos NOT REGEXP '^[a-zA-Z\s]+$' THEN
        SET error_msg = 'El campo apellido debe contener solo letras.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar el formato del correo
    IF NEW.doc_Correo NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' THEN
        SET error_msg = 'Formato de correo inválido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

     -- Validar que el teléfono no contenga el código de área
    IF NEW.doc_Telefono NOT REGEXP '^[0-9]+$' THEN
        SET error_msg = 'El teléfono debe obviar el codigo de area.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que el salario sea positivo y no mayor a 99,000
    IF NEW.doc_Salario <= 0 OR NEW.doc_Salario > 99000 THEN
        SET error_msg = 'El campo salario debe ser un número positivo y no mayor a 99,000.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

END //

DELIMITER ;

-- Inserción válida
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (1, 'Joel', 'Guzman', '1965-09-15', 'joelguzman@gmail.com', 40641865, 'Zona 5 Guatemala', 182118219, 5000, '2005-01-03');

-- Inserción válida con salario cercano al límite
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (2, 'Consuelo', 'Duarte', '1965-04-20', 'consueloddg@gmail.com', 39129192, 'Zona 1 Guatemala', 1821821021, 99000, '2010-02-01');

-- Inserción inválida
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (1, 'Joel121', 'Guzman', '1965-09-15', 'joelguzman@gmail.com', 40641865, 'Zona 5 Guatemala', 182118219, 5000, '2005-01-03');

-- Inserción inválida
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (1, 'Joel', 'Guzman121', '1965-09-15', 'joelguzman@gmail.com', 40641865, 'Zona 5 Guatemala', 182118219, 5000, '2005-01-03');

-- Inserción inválida
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (2, 'Consuelo', 'Duarte', '1965-04-20', 'consueloddg@', 39129192, 'Zona 1 Guatemala', 1821821021, 99000, '2010-02-01');

-- Inserción inválida
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (2, 'Consuelo', 'Duarte', '1965-04-20', 'consueloddg@hotmail.com', 39129192, 'Zona 1 Guatemala', 1821821021, -99000, '2010-02-01');

-- Inserción inválida
INSERT INTO docente (doc_id, doc_Nombres, doc_Apellidos, doc_FechaNacimiento, doc_Correo, doc_Telefono, doc_Direccion, doc_Dpi, doc_Salario, doc_FechaRegistro)
VALUES (2, 'Consuelo', 'Duarte', '1965-04-20', 'consueloddg@hotmail.com', 39129192, 'Zona 1 Guatemala', 1821821021, 100000, '2010-02-01');

-- Creacion de tabla pensum
CREATE TABLE `pensum` (
  `pen_id` int NOT NULL,
  `pen_idCurso` int NOT NULL,
  `pen_Nombre` varchar(45) NOT NULL,
  `pen_CreditosNecesarios` int NOT NULL,
  `pen_CreditosOtorgados` int NOT NULL,
  `pen_Obligatorio` tinyint NOT NULL,
  `pen_Plan` int NOT NULL,
  PRIMARY KEY (`pen_id`)
);

DELIMITER //

CREATE TRIGGER vali_pensum
BEFORE INSERT ON pensum
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);  -- Declarar la variable error_msg

    -- Validar que el crédito necesario sea positivo 
    IF NEW.pen_CreditosNecesarios <= 0  THEN
        SET error_msg = 'El campo de créditos necesarios debe ser un número positivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que el crédito otorgado sea positivo 
    IF NEW.pen_CreditosOtorgados <= 0  THEN
        SET error_msg = 'El campo de créditos otorgados debe ser un número positivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

END //

DELIMITER ;

CREATE TABLE `prerrequisito` (
  `pre_id` int NOT NULL AUTO_INCREMENT,
  `pre_idCurso` int NOT NULL,
  `pre_idCursoPre` int NOT NULL,
  PRIMARY KEY (`pre_id`),
  CONSTRAINT `fk_pre_idCurso` FOREIGN KEY (`pre_idCurso`) REFERENCES `curso` (`cur_id`),
  CONSTRAINT `fk_pre_idCursoPre` FOREIGN KEY (`pre_idCursoPre`) REFERENCES `curso` (`cur_id`)
);

DELIMITER //

CREATE TRIGGER vali_prerrequisito
BEFORE INSERT ON prerrequisito
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);
    DECLARE v_valid_curso INT;
    DECLARE v_valid_curso_pre INT;

    -- Validar existencia del curso principal
    SELECT COUNT(*) INTO v_valid_curso FROM curso WHERE cur_id = NEW.pre_idCurso;
    IF v_valid_curso = 0 THEN
        SET error_msg = 'El curso especificado no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar existencia del curso prerrequisito
    SELECT COUNT(*) INTO v_valid_curso_pre FROM curso WHERE cur_id = NEW.pre_idCursoPre;
    IF v_valid_curso_pre = 0 THEN
        SET error_msg = 'El curso prerrequisito especificado no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;
END //

DELIMITER ;


-- Crear la tabla seccion
CREATE TABLE seccion (
  `sec_id` INT NOT NULL AUTO_INCREMENT,
  `sec_ciclo` VARCHAR(2) NOT NULL,
  `sec_docente` INT NOT NULL,
  `sec_seccion` CHAR(1) NOT NULL,
  PRIMARY KEY (`sec_id`),
  KEY `idDocent_idx` (`sec_docente`),
  CONSTRAINT `idDocent` FOREIGN KEY (`sec_docente`) REFERENCES `docente` (`doc_id`)
);

DELIMITER //

CREATE TRIGGER vali_seccion
BEFORE INSERT ON seccion
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);

    -- Validar que el ciclo sea uno de los valores dados
    IF NEW.sec_ciclo NOT IN ('1S', '2S', 'VJ', 'VD') THEN
        SET error_msg = 'El campo de ciclo no es de los valores aceptados.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar la seccion
    IF ASCII(NEW.sec_seccion) < 65 OR ASCII(NEW.sec_seccion) > 90 THEN
        SET error_msg = 'El campo seccion debe ser una letra mayúscula.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que el docente exista
    IF (SELECT COUNT(*) FROM docente WHERE doc_id = NEW.sec_docente) = 0 THEN
        SET error_msg = 'El docente especificado no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;
END //

DELIMITER ;

-- Eliminar tabla 
DROP TABLE seccion;

-- Pruebas de insertar
--valida
INSERT INTO seccion (sec_ciclo, sec_docente, sec_seccion) VALUES ('1S', 1, 'A');
--invalida
INSERT INTO seccion (sec_ciclo, sec_docente, sec_seccion) VALUES ('1M', 1, 'A');
--invalida
INSERT INTO seccion (sec_ciclo, sec_docente, sec_seccion) VALUES ('1S', 3, 'A');
--invalida
INSERT INTO seccion (sec_ciclo, sec_docente, sec_seccion) VALUES ('1S', 2, 'a');
--invalida
INSERT INTO seccion (sec_ciclo, sec_docente, sec_seccion) VALUES ('1S', 2, 'AB');

-- Crear la tabla carrera
CREATE TABLE horario (
  `hor_id` INT NOT NULL AUTO_INCREMENT,
  `hor_seccion` INT NOT NULL,
  `hor_periodo` INT NOT NULL,
  `hor_dia` INT NOT NULL,
  `hor_salon` INT NOT NULL,
  PRIMARY KEY (`hor_id`),
  KEY `idPerio_idx` (`hor_seccion`),
  CONSTRAINT `idPerio` FOREIGN KEY (`hor_seccion`) REFERENCES `seccion` (`sec_id`)
);

DELIMITER //

CREATE TRIGGER vali_horario
BEFORE INSERT ON horario
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);

    -- Validar que el seccion exista
    IF (SELECT COUNT(*) FROM seccion WHERE sec_id = NEW.hor_seccion) = 0 THEN
        SET error_msg = 'La seccion especificado no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;
END //

DELIMITER ;

-- Eliminar tabla 
DROP TABLE horario;

-- pruebas de insertar 
--valida
INSERT INTO horario (hor_seccion, hor_periodo, hor_dia, hor_salon) VALUES (1, 1, 1, 101);
--invalida no hay ese seccion 
INSERT INTO horario (hor_seccion, hor_periodo, hor_dia, hor_salon) VALUES (2, 1, 1, 101);

-- Crear la tabla curso
CREATE TABLE curso (
  `cur_id` INT NOT NULL AUTO_INCREMENT,
  `cur_seccion` INT NOT NULL,
  `cur_carnet` INT NOT NULL,
  `nota` INT,
  `creditos_ganados` INT,
  PRIMARY KEY (`cur_id`),
  UNIQUE KEY `unique_seccion_carnet` (`cur_seccion`, `cur_carnet`), 
  CONSTRAINT `fk_seccion` FOREIGN KEY (`cur_seccion`) REFERENCES `seccion` (`sec_id`),
  CONSTRAINT `fk_estudiante` FOREIGN KEY (`cur_carnet`) REFERENCES `estudiantes` (`est_Carnet`)
);

DELIMITER //

CREATE TRIGGER vali_curso
BEFORE INSERT ON curso
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);

    -- Validar que la sección exista
    IF (SELECT COUNT(*) FROM seccion WHERE sec_id = NEW.cur_seccion) = 0 THEN
        SET error_msg = 'La sección especificada no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que el estudiante exista
    IF (SELECT COUNT(*) FROM estudiantes WHERE est_Carnet = NEW.cur_carnet) = 0 THEN
        SET error_msg = 'El estudiante especificado no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

END //

DELIMITER ;

-- Insertar un curso para un estudiante en una sección específica
INSERT INTO curso (cur_seccion, cur_carnet)
VALUES (1, 1);

-- Crear tabla notas
CREATE TABLE nota (
  `not_id` INT NOT NULL AUTO_INCREMENT,
  `not_seccion` INT NOT NULL,
  `not_carnet` INT NOT NULL,
  `not_zona` DECIMAL(5,2) NOT NULL,
  `not_examenfinal` DECIMAL(5,2) NOT NULL,
  `not_notafinal` INT,
  PRIMARY KEY (`not_id`),
  CONSTRAINT `fk_seccion_nota` FOREIGN KEY (`not_seccion`) REFERENCES `seccion` (`sec_id`),
  CONSTRAINT `fk_estudiante_nota` FOREIGN KEY (`not_carnet`) REFERENCES `estudiantes` (`est_Carnet`)
);
DELIMITER //

CREATE TRIGGER vali_nota
BEFORE INSERT ON nota
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);
    DECLARE nota_zona DECIMAL(5,2);
    DECLARE nota_final DECIMAL(5,2);
    DECLARE nota_entera INT;

    -- Validar que la sección exista
    IF (SELECT COUNT(*) FROM seccion WHERE sec_id = NEW.not_seccion) = 0 THEN
        SET error_msg = 'La sección especificada no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que el estudiante exista
    IF (SELECT COUNT(*) FROM estudiantes WHERE est_Carnet = NEW.not_carnet) = 0 THEN
        SET error_msg = 'El estudiante especificado no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Calcular la nota final redondeada al entero más cercano
    SET nota_zona = NEW.not_zona;
    SET nota_final = NEW.not_examenfinal;
    SET nota_entera = ROUND(nota_zona + nota_final);

    -- Asignar la nota final calculada a la columna not_notafinal
    SET NEW.not_notafinal = nota_entera;

    -- Actualizar la tabla de curso con la nota final y créditos ganados
    UPDATE curso
    SET nota = nota_entera,
        creditos_ganados = creditos_ganados + 3
    WHERE cur_seccion = NEW.not_seccion
        AND cur_carnet = NEW.not_carnet;

END //

DELIMITER ;

-- Insertar una nota para un estudiante en una sección específica
INSERT INTO nota (not_seccion, not_carnet, not_zona, not_examenfinal)
VALUES (1, 1, 8.5, 7.5);

-- Crear tabla desasignar
CREATE TABLE desasignar (
  `des_id` INT NOT NULL AUTO_INCREMENT,
  `des_seccion` INT NOT NULL,
  `des_carnet` INT NOT NULL,
  PRIMARY KEY (`des_id`),
  CONSTRAINT `fk_des_seccion` FOREIGN KEY (`des_seccion`) REFERENCES `seccion` (`sec_id`),
  CONSTRAINT `fk_des_estudiante` FOREIGN KEY (`des_carnet`) REFERENCES `estudiantes` (`est_Carnet`)
);

DELIMITER //

CREATE TRIGGER vali_desasig
BEFORE INSERT ON desasignar
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);

    -- Validar que el estudiante esté asignado a la sección que se desea desasignar
    IF (SELECT COUNT(*) FROM curso WHERE cur_seccion = NEW.des_seccion AND cur_carnet = NEW.des_carnet) = 0 THEN
        SET error_msg = 'El estudiante no está asignado a la sección especificada.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Eliminar la asignación del estudiante en la sección especificada
    DELETE FROM curso
    WHERE cur_seccion = NEW.des_seccion
        AND cur_carnet = NEW.des_carnet;

END //

DELIMITER ;

-- prueba
INSERT INTO desasignar (des_seccion, des_carnet)
VALUES (1, 1);
