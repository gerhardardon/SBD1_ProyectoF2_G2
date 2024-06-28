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
