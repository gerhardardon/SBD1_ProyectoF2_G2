# SBD1_ProyectoF2_G2
## Fase 2 - Grupo2 

## Descripcion 📘
a Facultad de Ingeniería de la Universidad de San Carlos de Guatemala ha decidido
continuar mejorando el sistema de control académico que lleva el registro de la población
estudiantil, por lo que se le requiere a usted para brindar una solución a nivel de base de
datos para que usted sea el encargado de proponer, diseñar e implementar todo el flujo de
datos asegurando la persistencia e integridad de toda la información que se registre.
Se le ha dado total libertad para crear los procedimientos, funciones y disparadores
automatizados para el buen funcionamiento de la base de datos respetando las principales
funcionalidades requeridas.

## Objetivos 📙
- Manejar basesv de datos relacionales 
- Creacion de Triggers, procedimientos, tablas y consultas
- Crear y entender diagramas entidad relacion
- Entender y diagramar casos de la vida real para la crecaion de tablas 

## Base de datos 📕
Para este proyecto se utilzo MySql debido a la facilidad de consultas y la disposicion de la misma db, tambien se escogio debido a las facilidades que ofrece el IDE de MySql Workbench, aunque la mayoria de consultas fueron generadas y testeadas desde la consola.

## ¿Por qué escoger MySQL? 🖥️🖱️

MySQL es uno de los sistemas de gestión de bases de datos relacionales más populares del mundo. Aquí hay algunas razones por las que podrías considerar elegir MySQL para tu proyecto:
Ventajas de MySQL

- Rendimiento y Eficiencia: MySQL está optimizado para ofrecer un alto rendimiento en aplicaciones de alta carga.
- Facilidad de Uso: Su configuración y administración son relativamente simples, lo que lo hace accesible incluso para desarrolladores principiantes.- 
- Compatibilidad: MySQL es compatible con una amplia variedad de sistemas operativos, incluidos Windows, Linux y macOS.
- Comunidad Activa: Hay una gran comunidad de usuarios y desarrolladores que pueden ofrecer soporte y compartir conocimientos.
- Soporte para Replicación: MySQL soporta la replicación, lo que permite crear copias de seguridad y mejorar la disponibilidad de los datos.
- Flexibilidad: Soporta diferentes motores de almacenamiento, como InnoDB y MyISAM, lo que permite ajustar el rendimiento según las necesidades del proyecto.
- Open Source: MySQL es de código abierto, lo que permite acceso gratuito y la posibilidad de modificarlo según tus necesidades.

### Cómo ingresar a la consola de MySQL ⌨️

Para ingresar a la consola de MySQL, necesitas tener MySQL instalado en tu sistema. Una vez instalado, sigue estos pasos:

Abrir la terminal (o el símbolo del sistema en Windows).
Ejecutar el siguiente comando:

```mysql -u tu_usuario -p```

Introduce tu contraseña

Crear una base de datos
Una vez que estés en la consola de MySQL, puedes crear una nueva base de datos con el siguiente comando:
```
    CREATE DATABASE nombre_de_la_base_de_datos;
```
Crear tablas
Para crear una tabla dentro de la base de datos, primero necesitas seleccionar la base de datos que acabas de crear:
```
    USE nombre_de_la_base_de_datos;
```

## Sobre nuestra base de datos 🛠️⚙️
Para esta fase se uso la base de datos *prueba* en donde se utilizaron consultas, triggers, procedures y functions para poder desplegar, crear y manejar la informacion de manera efectiva. 

Para un mejor entendimiento de la base de datos se puede apreciar el modelo entidad relacion de la misma db
![](/MODELOER.png)

Ademas en la carpeta */borradores* podras encontrar la creacionde las tablas que se utilizaron de forma bien definida 
```CREATE TABLE plan (
  pla_id INT NOT NULL AUTO_INCREMENT,
  pla_plan VARCHAR(15) NOT NULL,
  PRIMARY KEY (pla_id)
);
```
Columnas: pla_id (clave primaria, auto_increment) y pla_plan (nombre del plan).
Claves: Clave primaria pla_id.

```
CREATE TABLE carrera (
  car_id INT NOT NULL AUTO_INCREMENT,
  car_Nombre VARCHAR(45) COLLATE armscii8_bin DEFAULT NULL,
  PRIMARY KEY (car_id),
  UNIQUE KEY Nombre_UNIQUE (car_Nombre)
);
```
Columnas: car_id (clave primaria, auto_increment) y car_Nombre (nombre de la carrera, único).
    Claves: Clave primaria car_id, clave única Nombre_UNIQUE en car_Nombre.


```
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
```
Columnas: Información detallada del estudiante.
Claves: Clave primaria est_Carnet.
Relaciones:

est_Carrera con carrera (car_id).
est_Plan con plan (pla_id).
```

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
```
Columnas: Información detallada del docente.
Claves: Clave primaria doc_id.
```
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
```
Columnas: Información del pensum.
Claves: Clave primaria pen_id.
Relaciones:

pen_idCurso con curso (cur_id).
pen_Plan con plan (pla_id).
```
CREATE TABLE `prerrequisito` (
  `pre_id` int NOT NULL AUTO_INCREMENT,
  `pre_idCurso` int NOT NULL,
  `pre_idCursoPre` int NOT NULL,
  PRIMARY KEY (`pre_id`),
  CONSTRAINT `fk_pre_idCurso` FOREIGN KEY (`pre_idCurso`) REFERENCES `curso` (`cur_id`),
  CONSTRAINT `fk_pre_idCursoPre` FOREIGN KEY (`pre_idCursoPre`) REFERENCES `curso` (`cur_id`)
);
```
Columnas: Información del prerrequisito.
Claves: Clave primaria pre_id.
Relaciones:

pre_idCurso con curso (cur_id).
pre_idCursoPre con curso (cur_id).
```

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
```
Columnas: Información de la sección.
Claves: Clave primaria sec_id.
Relaciones: sec_docente con docente (doc_id).
```

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
```
Columnas: Información del horario.
Claves: Clave primaria hor_id.
Relaciones: hor_seccion con seccion (sec_id).
```

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
```
Columnas: Información del curso.
Claves: Clave primaria cur_id, clave única unique_seccion_carnet (combinación de cur_seccion y cur_carnet).
```

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
```
Columnas: Información de las notas.
Claves: Clave primaria not_id.
Relaciones:

not_seccion con seccion (sec_id).
not_carnet con estudiantes (est_Carnet).
```

-- Crear tabla desasignar
CREATE TABLE desasignar (
  `des_id` INT NOT NULL AUTO_INCREMENT,
  `des_seccion` INT NOT NULL,
  `des_carnet` INT NOT NULL,
  PRIMARY KEY (`des_id`),
  CONSTRAINT `fk_des_seccion` FOREIGN KEY (`des_seccion`) REFERENCES `seccion` (`sec_id`),
  CONSTRAINT `fk_des_estudiante` FOREIGN KEY (`des_carnet`) REFERENCES `estudiantes` (`est_Carnet`)
);
```
Columnas: Información de desasignación de secciones.
Claves: Clave primaria des_id.
Relaciones:
des
```

CREATE TABLE periodo (
  `per_id` INT NOT NULL AUTO_INCREMENT,
  `horas` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`per_id`)
);
```
Columnas: Información de periodos de secciones.
Claves: Clave primaria per_id
```

CREATE TABLE transacciones (
  id INT NOT NULL AUTO_INCREMENT,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tabla VARCHAR(50) NOT NULL,
  operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  PRIMARY KEY (id)
); 
```
En esta ultima tabla s+por medio de triggers se guardan todas las modificaciones que se hagan a las siguientes tablas y puedan ser de interes:
Carrera
• Inscripción
• Estudiante
• Catedrático
• Pensum
• Curso
• Asignación
• Sección
• Horario
• Prerrequisito

### Conclusiones 📚
- Tablas para Información Básica:

plan: Almacena planes o programas.
    carrera: Almacena carreras o especialidades.
    estudiantes: Almacena información de los estudiantes, incluyendo su carrera y plan asignados.

- Tablas para Información del Personal:

docente: Almacena información sobre los docentes o profesores.

- Tablas para Gestión de Cursos y Currículos:

pensum: Describe el currículo, incluyendo cursos obligatorios y optativos.
    prerrequisito: Gestiona los prerrequisitos de los cursos.

- Tablas para Secciones de Cursos y Horarios:

seccion: Representa secciones de cursos con docentes asignados.
    horario: Gestiona los horarios de las secciones de los cursos.

- Tablas para Inscripción y Calificaciones de Estudiantes en Cursos:

curso: Rastrea la inscripción de estudiantes en cursos.
    nota: Almacena las calificaciones de los estudiantes para las secciones de los cursos.

- Tabla Adicional:

desasignar: Maneja la desinscripción de secciones de cursos para estudiantes.
