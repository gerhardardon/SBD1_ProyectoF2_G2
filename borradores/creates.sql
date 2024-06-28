CREATE TABLE plan (
  pla_id INT NOT NULL AUTO_INCREMENT,
  pla_plan VARCHAR(15) NOT NULL,
  PRIMARY KEY (pla_id)
);

CREATE TABLE carrera (
  car_id INT NOT NULL AUTO_INCREMENT,
  car_Nombre VARCHAR(45) COLLATE armscii8_bin DEFAULT NULL,
  PRIMARY KEY (car_id),
  UNIQUE KEY Nombre_UNIQUE (car_Nombre)
);

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

CREATE TABLE `prerrequisito` (
  `pre_id` int NOT NULL AUTO_INCREMENT,
  `pre_idCurso` int NOT NULL,
  `pre_idCursoPre` int NOT NULL,
  PRIMARY KEY (`pre_id`),
  CONSTRAINT `fk_pre_idCurso` FOREIGN KEY (`pre_idCurso`) REFERENCES `curso` (`cur_id`),
  CONSTRAINT `fk_pre_idCursoPre` FOREIGN KEY (`pre_idCursoPre`) REFERENCES `curso` (`cur_id`)
);

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

-- Crear tabla desasignar
CREATE TABLE desasignar (
  `des_id` INT NOT NULL AUTO_INCREMENT,
  `des_seccion` INT NOT NULL,
  `des_carnet` INT NOT NULL,
  PRIMARY KEY (`des_id`),
  CONSTRAINT `fk_des_seccion` FOREIGN KEY (`des_seccion`) REFERENCES `seccion` (`sec_id`),
  CONSTRAINT `fk_des_estudiante` FOREIGN KEY (`des_carnet`) REFERENCES `estudiantes` (`est_Carnet`)
);


CREATE TABLE periodo (
  `per_id` INT NOT NULL AUTO_INCREMENT,
  `horas` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`per_id`)
);

CREATE TABLE transacciones (
  id INT NOT NULL AUTO_INCREMENT,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tabla VARCHAR(50) NOT NULL,
  operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  PRIMARY KEY (id)
);