CREATE DATABASE  IF NOT EXISTS `Proyecto`;
USE `Proyecto`;

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

-- Crear tabla periodo
CREATE TABLE periodo (
  `per_id` INT NOT NULL AUTO_INCREMENT,
  `horas` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`per_id`)
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
