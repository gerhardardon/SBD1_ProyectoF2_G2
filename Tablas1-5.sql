CREATE DATABASE  IF NOT EXISTS `Proyecto`;
USE `Proyecto`;

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


-- Creacion de tabla pensum
CREATE TABLE `pensum` (
  `pen_id` int NOT NULL AUTO_INCREMENT,
  `pen_idCurso` int NOT NULL,
  `pen_Nombre` varchar(45) NOT NULL,
  `pen_CreditosNecesarios` int NOT NULL,
  `pen_CreditosOtorgados` int NOT NULL,
  `pen_Obligatorio` tinyint NOT NULL,
  `pen_Plan` int NOT NULL,
  PRIMARY KEY (`pen_id`),
  CONSTRAINT `fk_idCurso` FOREIGN KEY (`pen_idCurso`) REFERENCES `curso` (`cur_id`),
  CONSTRAINT `fk_Plan` FOREIGN KEY (`pen_Plan`) REFERENCES `plan` (`pla_id`)
);


DELIMITER //

CREATE TRIGGER vali_pensum
BEFORE INSERT ON pensum
FOR EACH ROW
BEGIN
    DECLARE error_msg VARCHAR(255);
    DECLARE v_valid_curso INT;
    DECLARE v_valid_plan INT;

    -- Validar que el crédito necesario sea positivo 
    IF NEW.pen_CreditosNecesarios <= 0 THEN
        SET error_msg = 'El campo de créditos necesarios debe ser un número positivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar que el crédito otorgado sea positivo 
    IF NEW.pen_CreditosOtorgados <= 0 THEN
        SET error_msg = 'El campo de créditos otorgados debe ser un número positivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar existencia del curso
    SELECT COUNT(*) INTO v_valid_curso FROM curso WHERE cur_id = NEW.pen_idCurso;
    IF v_valid_curso = 0 THEN
        SET error_msg = 'El curso no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
    END IF;

    -- Validar existencia del plan
    SELECT COUNT(*) INTO v_valid_plan FROM plan WHERE pla_id = NEW.pen_Plan;
    IF v_valid_plan = 0 THEN
        SET error_msg = 'El plan no existe.';
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
