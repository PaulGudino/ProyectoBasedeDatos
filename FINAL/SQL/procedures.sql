	/*PROCEDURE DE HISTORIAL FINANZAS*/
/*ACTUALIZA EL VALOR DEL GASTO REGISTRADO EN LA TABLA HISTORIAL FINANZAS, DE ACUERDO A LA CATEGORIA */
DELIMITER ||
CREATE PROCEDURE CATEGORIA_ALIMENTACION (IN CATEGORIA INT, IN VALOR DECIMAL, IN MES_N INT, IN ANIO_N INT, IN FAMILIA_N INT)
BEGIN
CASE CATEGORIA
WHEN 1 THEN UPDATE HISTORIALFINANZAS SET ALIMENTACION = ALIMENTACION + VALOR WHERE MES=MES_N AND AÑO = ANIO_N AND ID_FAMILIA=FAMILIA_N;
WHEN 2 THEN UPDATE HISTORIALFINANZAS SET SALUD = SALUD + VALOR WHERE MES=MES_N AND AÑO = ANIO_N AND ID_FAMILIA=FAMILIA_N;
WHEN 3 THEN UPDATE HISTORIALFINANZAS SET VIVIENDA = VIVIENDA + VALOR WHERE MES=MES_N AND AÑO = ANIO_N AND ID_FAMILIA=FAMILIA_N;
WHEN 4 THEN UPDATE HISTORIALFINANZAS SET VESTIMENTA = VESTIMENTA + VALOR WHERE MES=MES_N AND AÑO = ANIO_N AND ID_FAMILIA=FAMILIA_N;
WHEN 5 THEN UPDATE HISTORIALFINANZAS SET DISTRACCION = DISTRACCION + VALOR WHERE MES=MES_N AND AÑO = ANIO_N AND ID_FAMILIA=FAMILIA_N;
ELSE SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE LA CATEGORIA";
END CASE;
END ||
DELIMITER ;
CALL CATEGORIA_ALIMENTACION(3,5813.00,5,2020,6);

/*PROCEDURE QUE MUESTRAS TODOS LOS MENSAJES CORRESPONDIENTES A UNA FAMILIA*/
DELIMITER ||
CREATE PROCEDURE BUZON_FAMILIA (IN NUMERO INT)
BEGIN
SET @FAMILIA = (SELECT ID_HOGAR FROM HOGAR WHERE ID_HOGAR = NUMERO);
IF(@FAMILIA IS NULL) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE LA FAMILIA";
ELSE SELECT MENSAJE,FECHA FROM BUZON, ADMINISTRADOR WHERE USUARIO = USUARIO_ADMIN AND ID_FAMILIA = NUMERO;
END IF;
END ||
DELIITER ;
CALL BUZON_FAMLIA(5);

/*PROCEDURE QUE MUESTRA EL VALOR TOTAL POR CATEGORIA DE LA FAMILIA DEPENDIENDO DEL AÑO*/
DELIMITER ||
CREATE PROCEDURE CATEGORIA_AÑO (IN ANIO INT, IN FAMILIA INT)
BEGIN
SET @VALIDACION = (SELECT AÑO FROM HISTORIALFINANZAS WHERE AÑO = ANIO LIMIT 1);
IF (@VALIDACION IS NULL OR ANIO IS NULL) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE EL AÑO";
END IF;
SELECT AÑO, ID_FAMILIA, SUM(ALIMENTACION) AS TOTAL_ALIMETACION, SUM(SALUD) AS TOTAL_SALUD, SUM(VIVIENDA) AS TOTAL_VIVIENDA, SUM(VESTIMENTA) AS TOTAL_VESTIMENTA, SUM(DISTRACCION) AS TOTAL_DISTACCION FROM HISTORIALFINANZAS 
GROUP BY AÑO ,ID_FAMILIA HAVING AÑO = ANIO AND ID_FAMILIA = FAMILIA;
END ||
DELIMITER ;
CALL CATEGORIA_AÑO(2020,5);

/*PROCEDURE QUE MUESTRA EL TOTAL DE GASTOS E INGRESOS POR FAMILIA DE ACUERDO A UN AÑO */
DELIMITER ||
CREATE PROCEDURE GASTOS_INGRESOS_AÑO (IN ANIO INT, IN FAMILIA INT) 
BEGIN
IF (@VALIDACION IS NULL OR ANIO IS NULL) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE EL AÑO";
END IF;
SELECT SUM(TOTAL_GASTOS) AS TOTAL_GASTOS_AÑO, SUM(TOTAL_INGRESOS)AS TOTAL_INGRESOS_AÑO, ID_FAMILIA 
FROM HISTORIALFINANZAS WHERE AÑO = ANIO GROUP BY
ID_FAMILIA HAVING ID_FAMILIA = FAMILIA;
END ||
DELIMITER ;
CALL GASTOS_INGRESOS_AÑO(2020,5);

/*PROCEDURE QUE VALIDA SI LA CATEGORIA SE ENCENTRA EN LA TABLA CATEGORIAS*/
DELIMITER ||
CREATE PROCEDURE VALIDAR_CATEGORIA(IN CATEGORIA_N INT)
BEGIN
SET @VALIDACION = CATEGORIA_N IN (SELECT ID_CATEGORIA FROM CATEGORIAS);
IF(NOT @VALIDACION = 1) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE LA CATEGORIA";
END IF ;
END ||
DELIMITER ;
CALL VALIDAR_CATEGORIA(3);

/*PROCEDURE QUE MUESTRA EL MAYOR GASTO DE LA FAMILIA DE ACUERDO A UNA CATEGORIA*/
DELIMITER ||
CREATE PROCEDURE MAYOR_GASTO_CATEGORIA(IN FAMILIA INT, IN CATEGORIA INT)
BEGIN
CALL VALIDAR_CATEGORIA(CATEGORIA);
CASE CATEGORIA
WHEN 1 THEN SELECT AÑO, MES, ALIMENTACION, HF.ID_FAMILIA
FROM HISTORIALFINANZAS HF, (SELECT MAX(ALIMENTACION) AS MAXIMO, ID_FAMILIA FROM HISTORIALFINANZAS GROUP BY ID_FAMILIA HAVING ID_FAMILIA = FAMILIA) AS T
WHERE HF.ID_FAMILIA = T.ID_FAMILIA AND HF.ALIMENTACION = T.MAXIMO;

WHEN 2 THEN SELECT AÑO, MES, SALUD, HF.ID_FAMILIA
FROM HISTORIALFINANZAS HF, (SELECT MAX(SALUD) AS MAXIMO, ID_FAMILIA FROM HISTORIALFINANZAS GROUP BY ID_FAMILIA HAVING ID_FAMILIA = FAMILIA) AS T
WHERE HF.ID_FAMILIA = T.ID_FAMILIA AND HF.SALUD = T.MAXIMO;

WHEN 3 THEN SELECT AÑO, MES, VIVIENDA, HF.ID_FAMILIA
FROM HISTORIALFINANZAS HF, (SELECT MAX(VIVIENDA) AS MAXIMO, ID_FAMILIA FROM HISTORIALFINANZAS GROUP BY ID_FAMILIA HAVING ID_FAMILIA = FAMILIA) AS T
WHERE HF.ID_FAMILIA = T.ID_FAMILIA AND HF.VIVIENDA = T.MAXIMO;

WHEN 4 THEN SELECT AÑO, MES, VESTIMENTA, HF.ID_FAMILIA
FROM HISTORIALFINANZAS HF, (SELECT MAX(VESTIMENTA) AS MAXIMO, ID_FAMILIA FROM HISTORIALFINANZAS GROUP BY ID_FAMILIA HAVING ID_FAMILIA = FAMILIA) AS T
WHERE HF.ID_FAMILIA = T.ID_FAMILIA AND HF.VESTIMENTA = T.MAXIMO;

WHEN 5 THEN SELECT AÑO, MES, DISTRACCION, HF.ID_FAMILIA
FROM HISTORIALFINANZAS HF, (SELECT MAX(DISTRACCION) AS MAXIMO, ID_FAMILIA FROM HISTORIALFINANZAS GROUP BY ID_FAMILIA HAVING ID_FAMILIA = FAMILIA) AS T
WHERE HF.ID_FAMILIA = T.ID_FAMILIA AND HF.DISTRACCION = T.MAXIMO;
END CASE;
END ||
DELIMITER ;
CALL MAYOR_GASTO_CATEGORIA(2020,5);


/*PROCEDUCE QUE MUESTRA LOS GASTOS QUE ESTAN PROXIMOS A VENCER CORRESPONDIENTE A UNA FAMILIA*/
DELIMITER ||
CREATE PROCEDURE PRIORIZACION_GASTOS(IN FAMILIA INT)
BEGIN
SET @VALIDACION = (SELECT ID_HOGAR FROM HOGAR WHERE ID_HOGAR = FAMILIA LIMIT 1);
IF(@VALIDACION IS NULL)THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE LA FAMILIA";
END IF;
SELECT NOMBRE, FECHA_VENCIMIENTO, ID_FAMILIA,TIMESTAMPDIFF(DAY, CURDATE() , T.FECHA_VENCIMIENTO) AS DIFERENCIA_DIAS 
FROM ADMINISTRADOR AD,(SELECT * FROM GASTOS WHERE FECHA_VENCIMIENTO IS NOT NULL) AS T 
WHERE USUARIO_ADMIN = AD.USUARIO AND ID_FAMILIA = FAMILIA AND MONTH(FECHA_VENCIMIENTO) = MONTH(NOW())
ORDER BY DIFERENCIA_DIAS DESC;
END ||
DELIMITER ;
CALL PRIORIZACION_GASTOS(17);

/*PROCEDURE QUE VERIFICA SI UN ADMINISTRADOR ESTA REGISTRADO EN LA BASE DE DATOS */
DELIMITER ||
CREATE PROCEDURE VERIFICAR_ADMINISTRADOR(IN INGRESO_ADMINISTRADOR VARCHAR(15), IN CONTRASEÑA_N VARCHAR(15))
BEGIN
SET @VALIDACION_USUARIO = (SELECT USUARIO FROM ADMINISTRADOR WHERE USUARIO = INGRESO_ADMINISTRADOR);
SET @VALIDACION_CONTRASENIA = (SELECT USUARIO FROM ADMINISTRADOR WHERE USUARIO = INGRESO_ADMINISTRADOR AND CONTRASEÑA = CONTRASEÑA_N);
IF(@VALIDACION_USUARIO IS NULL) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE USUARIO";
END IF;
IF(@VALIDACION_CONTRASENIA IS NULL) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "CONTRASEÑA INCORRECTA";
END IF;
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "INGRESO EXISTOSO";
END ||
DELIMITER ;
CALL VERIFICAR_ADMINISTRADOR("PAULMGP", "OLAKEASE");

/*PROCEDURE QUE MUESTRA EL REPORTE FINANCIERO DE UNA FAMILIA*/
DELIMITER ||
CREATE PROCEDURE REPORTE_FINANCIERO (IN FAMILIA INT)
BEGIN
SET @VALIDACION = (SELECT ID_HOGAR FROM HOGAR WHERE ID_HOGAR = FAMILIA LIMIT 1);
IF(@VALIDACION IS NULL)THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO EXISTE LA FAMILIA";
END IF;
SELECT * FROM HISTORIALFINANZAS WHERE ID_FAMILIA = FAMILIA;
END ||
DELIMITER ;
CALL REPORTE_FINANCIERO(10);

/*PROCEDURE QUE MUESTRA LOS MENSAJES QUE LE PERTENECEN AL ADMINISTRADOR*/	
DELIMITER ||
CREATE PROCEDURE BANDEJA_ENTRADA(IN INGRESO_ADMINISTRADOR VARCHAR(15))
BEGIN
SET @VALIDACION_USUARIO = (SELECT USUARIO FROM ADMINISTRADOR WHERE USUARIO = INGRESO_ADMINISTRADOR);
IF (@VALIDACION_USUARIO IS NULL) THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO ES ADMINISTRADOR";
END IF; 
SELECT * FROM BUZON WHERE INGRESO_ADMINISTRADOR = USUARIO_ADMIN;
END ||
DELIMITER ;
CALL BANDEJA_ENTRADA("MAGNUS");

/*PROCEDURE QUE PERMITE ELMINAR UN GASTO RECIENTE */
DELIMITER ||
CREATE PROCEDURE ELIMINAR_GASTO(IN FAMILIA INT)
BEGIN

SET@GASTO_ELIMINAR = (SELECT NOMBRE FROM GASTOS WHERE USUARIO_ADMIN IN (SELECT A.USUARIO FROM ADMINISTRADOR A WHERE ID_FAMILIA = FAMILIA) ORDER BY FECHA_EMISION DESC LIMIT 1);
SET@FECHA_ELMINAR = (SELECT FECHA_EMISION FROM GASTOS WHERE USUARIO_ADMIN IN (SELECT A.USUARIO FROM ADMINISTRADOR A WHERE ID_FAMILIA = FAMILIA) ORDER BY FECHA_EMISION DESC LIMIT 1);
SET@USUARIO_ELIMINAR = (SELECT USUARIO_ADMIN FROM GASTOS WHERE USUARIO_ADMIN IN (SELECT A.USUARIO FROM ADMINISTRADOR A WHERE ID_FAMILIA = FAMILIA) ORDER BY FECHA_EMISION DESC LIMIT 1);
IF(@GASTO_ELIMINAR IS NULL)THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El gasto no existe";
END IF;
DELETE FROM GASTOS WHERE NOMBRE = @GASTO_ELIMINAR AND FECHA_EMISION = @FECHA_ELIMINAR AND USUARIO_ADMIN = USUARIO_ELIMINAR;
END ||
DELIMTER ;
CALL ELIMINAR_GASTO(4);

/*PROCEDURE QUE ACTUALIZA EL RESUMEN EXCEDENTE DE LA TABLA HISTORIAL FINANZAS*/
DELIMITER ||
CREATE PROCEDURE ACTUALIZAR_RESUMEN (IN MESX INT, IN ANIO YEAR, IN FAMILIA INT)
BEGIN
UPDATE HISTORIALFINANZAS SET RESUMEN_EXCEDENTE = TOTAL_INGRESOS - TOTAL_GASTOS WHERE MES = MESX AND AÑO = ANIO AND ID_FAMILIA = FAMILIA;
END ||
DELIMITER;
CALL ACTUALIZAR_RESUMEN(5,2020,4);

/*PROCEDURE QUE VERIFICA EL PARENTESCO */
DELIMITER ||
CREATE PROCEDURE PERTENECEN_A_LA_MISMA_FAMILIA(IN ADMINISTRADOR VARCHAR(15), IN MIEMBROFAM VARCHAR (15))
BEGIN
SET @VALIDACION1 = (SELECT ID_FAMILIA FROM ADMINISTRADOR WHERE USUARIO = ADMINISTRADOR LIMIT 1);
SET @VALIDACION2 = (SELECT ID_FAMILIA FROM MIEMBROS_FAMILIA WHERE USUARIOMF = MIEMBROFAM LIMIT 1);
IF(NOT @VALIDACION1 = @VALIDACION2)THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "NO SON FAMILIA";
END IF;
END ||
DELIMITER ;
CALL PERTENECEN_A_LA_MISMA_FAMILIA("MAGNUS", "PAULMGP");
/* -------------------------PRCEDURES GENERALES---------------------------*/
/*PROCEDURES DE HOGAR*/

-- INSERT: INGRESA DATOS
DELIMITER ||
CREATE PROCEDURE INSERT_HOGAR(IN NOMBRE_FAMILIA VARCHAR(50))
BEGIN
	INSERT INTO HOGAR(NOMBRE_FAMILIA) VALUES(NOMBRE_FAMILIA); 
END ||
DELIMITER ;
CALL INSERT_HOGAR("MATAMOROS LUZ");

-- UPDATE : ACTUALIZA DATOS
DELIMITER ||
CREATE PROCEDURE UPDATE_HOGAR(IN ID INT, IN NOMBRE_FAMILIA VARCHAR(50))
BEGIN
	UPDATE HOGAR SET NOMBRE_FAMILA = NOMBRE_FAMILIA WHERE ID_HOGAR = ID;
END ||
DELIMITER ;
CALL UPDATE_HOGAR(1,"PLAZA CAMPOS");

-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE DELETE_HOGAR(IN ID INT)
BEGIN
DELETE FROM HOGAR WHERE ID_HOGAR = ID;
END ||
DELIMITER ;
CALL DELETE_HOGAR(5);

/*PROCEDURES ADMINISTRADOR*/
-- INSERT: INGRESA DATOS
DELIMITER ||
CREATE PROCEDURE INGRESO_ADMINISTRADOR(IN USUARIO_N VARCHAR(15), IN CONTRASEÑA_N VARCHAR(15), IN ID_FAMILIA_N INT )
BEGIN
	INSERT INTO ADMINISTRADOR(USUARIO, CONTRASEÑA, ID_FAMILIA) VALUES (USUARIO_N, CONTRASEÑA_N, ID_FAMILIA_N);
END ||
DELIMITER ;
CALL INGRESO_ADMINISTRADOR("USUARIOANONIMO", "OLAMUNDO", 5);

-- UPDATE : ACTUALIZA DATOS
DELIMITER ||
CREATE PROCEDURE ACTUALIZAR_ADMINISTRADOR(IN USUARIO_N VARCHAR(15), IN CONTRASEÑA_N VARCHAR(15), IN ID_FAMILIA_N INT)
BEGIN
	UPDATE ADMINISTRADOR SET USUARIO = USUARIO_N, CONTRASEÑA = CONTRASEÑA_N, ID_FAMILIA = ID_FAMILIA WHERE ID_FAMILIA = ID_FAMILIA_N;
END ||
DELIMITER ;
CALL ACTUALIZAR_ADMINISTRADOR("USUARIOANONIMO", "OLAMUNDO", 5)

-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE ELIMINAR_ADMINISTRADOR(IN ID_FAMILIA_N INT)
BEGIN
	DELETE FROM ADMINISTRADOR WHERE ID_FAMILIA= ID_FAMILIA_N;
END ||
DELIMITER ;
CALL ELIMINAR_ADMINISTRADOR(5);

/*PROCEDURES MIEMBROS FAMILIA*/
-- INSERT: INGRESA DATOS
DELIMITER ||
CREATE PROCEDURE INGRESO_MIEMBRO(IN USUARIO VARCHAR(15), IN CONTRASEÑA_N VARCHAR(15), IN ID_FAMILIA_N INT )
BEGIN
	INSERT INTO MIEMBROS_FAMILIA(USUARIOMF, CONTRASEÑA, ID_FAMILIA) VALUES (USUARIO, CONTRASEÑA_N, ID_FAMILIA_N);
END ||
DELIMITER ;
CALL INGRESO_MIEMBRO("USUARIOFAMILIA", "OLAMUNDO", 5);

-- UPDATE : ACTUALIZA DATOS
DELIMITER ||
CREATE PROCEDURE ACTUALIZAR_MIEMBRO(IN USUARIO VARCHAR(15), IN CONTRASEÑA_N VARCHAR(15), IN ID_FAMILIA_N INT)
BEGIN
	UPDATE MIEMBROS_FAMILIA SET USUARIOMF = USUARIO, CONTRASEÑA = CONTRASEÑA_N, ID_FAMILIA = ID_FAMILIA_N WHERE ID_FAMILIA = ID_FAMILIA_N;
END ||
DELIMITER ;
CALL ACTUALIZAR_MIEMBRO("USUARIOFAMILIA", "OLAMUNDO", 5);

-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE ELIMINAR_MIEMBRO(IN ID_FAMILIA_N INT)
BEGIN
	DELETE FROM MIEMBROS_FAMILIA WHERE ID_FAMILIA= ID_FAMILIA_N;
END ||
DELIMITER ;
CALL ELIMINAR_MIEMBRO(5);

/*PROCEDURES DE BUZON*/
-- INSERT: INGRESA DATOS
DELIMITER ||
CREATE PROCEDURE INSERT_BUZON(
IN MENSAJE_N VARCHAR(200), 
IN ADMIN_N VARCHAR(15), 
IN MIEMBRO VARCHAR(15),
IN GASTOS VARCHAR(15)
)
BEGIN
INSERT INTO BUZON(MENSAJE,USUARIO_ADMIN,USUARIOMF,NOMBRE_GASTOS,FECHA,HORA) 
VALUES (MENSAJE, ADMISN_N, MIEMBRO, GASTOS, CURRENT_DATE(), CURRENT_TIME());
END ||
DELIMITER ;
CALL INSERT_BUZON("HOLA", "JOSELUISXD", "LEONARDOCAMPOS", "PRUEBA");

-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE DELETE_BUZON(IN ID INT)
BEGIN
	DELETE FROM BUZON WHERE ID_MENSAJE =ID;
END ||
DELIMITER ;
CALL DELETE_BUZON(15);
/*PROCEDURE INGRESOS*/

-- INSERT: INGRESA DATOS 
DELIMITER ||
CREATE PROCEDURE INSERT_INGRESOS(IN USUARIO_N VARCHAR(15), IN USUARIO_ADMIN_N VARCHAR(15), IN FECHA DATE)
BEGIN
	INSERT INTO INGRESOS(USUARIO, USUARIO_ADMIN, FECHA_INGRESO) VALUES(USUARIO_N, USUARIO_ADMIN_N, FECHA);
END ||
DELIMITER ;
CALL INSERT_INGRESOS("PORTALES","PORTALES","2021-07-03");
-- UPDATE : ACTUALIZA DATOS
DELIMITER ||
CREATE PROCEDURE UPDATE_INGRESOS(IN USUARIO_N VARCHAR(15), IN USUARIO_ADMIN_N VARCHAR(15), IN ID INT )
BEGIN
	UPDATE INGRESOS SET ID_INGRESOS = ID WHERE USUARIO = USUARIO_N AND USUARIO_ADMIN =USUARIO_ADMIN_N;
END ||
DELIMITER ;
CALL UPDATE_INGRESOS("PORTALES","PORTALES",23);
-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE DELETE_INGRESOS(IN ID INT)
BEGIN
	DELETE FROM INGRESOS WHERE ID_INGRESOS = ID;
END ||
DELIMITER ;
CALL DELETE_INGRESOS(23)

/*PROCEDURES GASTOS*/
-- INSERT: INGRESA DATOS
DELIMITER ||
CREATE PROCEDURE INGRESO_GASTOS(IN NOMBRE_N VARCHAR(100), IN VALOR_N DECIMAL(8,2), IN FECHA_EMISION_N DATE, IN FECHA_VENCIMIENTO_N DATE, IN USUARIO_ADMI_N VARCHAR(15), IN ID_CATEGORIA_N INT, IN USUARIO_N VARCHAR(15))
BEGIN
	INSERT INTO GASTOS(NOMBRE, VALOR, FECHA_EMISION, FECHA_VENCIMIENTO, USUARIO_ADMI, ID_CATEGORIA) VALUES (NOMBRE_N, VALOR_N, FECHA_EMISION_N, FECHA_VENCIMIENTO_N, USUARIO_ADMI_N, ID_CATEGORIA_N);
END 
DELIMITER ;
CALL INGRESO_GASTOS("PRUEBA", 25.20, "2020-05-25", "2020-05-26", "MAGNUS", 3, "MAGNUS" );

-- UPDATE : ACTUALIZA DATOS
DELIMITER ||
CREATE PROCEDURE ACTUALIZAR_GASTOS(IN NOMBRE_N VARCHAR(100), IN VALOR_N DECIMAL(8,2), IN FECHA_EMISION_N DATE, IN FECHA_VENCIMIENTO_N DATE, IN USUARIO_ADMIN_N VARCHAR(15))
BEGIN
	UPDATE GASTOS SET NOMBRE = NOMBRE_N, VALOR = VALOR_N , FECHA_EMISION = FECHA_EMISION_N, FECHA_VENCIMIENTO = FECHA_VENCIMIENTO_N, USUARIO_ADMIN = USUARIO_ADMIN_N WHERE NOMBRE = NOMBRE_N;
END
DELIMITER ;
CALL ACTUALIZAR_GASTOS("PRUEBA", 25.20, "2020-05-25", "2020-05-26", "MAGNUS", 3, "MAGNUS");

-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE ELIMINAR_GASTOS(IN NOMBRE_N VARCHAR(100), IN VALOR_N DECIMAL(8,2), IN FECHA_EMISION_N DATE, IN FECHA_VENCIMIENTO_N DATE, IN USUARIO_ADMIN_N VARCHAR(15))
BEGIN
	DELETE FROM  GASTOS WHERE NOMBRE = NOMBRE_N AND  VALOR = VALOR_N AND FECHA_EMISION = FECHA_EMISION_N AND FECHA_VENCIMIENTO = FECHA_VENCIMIENTO_N AND USUARIO_ADMIN = USUARIO_ADMIN_N;
END ||
DELIMITER ;
CALL ELIMINAR_GASTOS("PRUEBA", 25.20, "2020-05-25", "2020-05-26", "MAGNUS", 3, "MAGNUS");

/*PROCEDURES USUARIOS*/
-- INSERT: INGRESA DATOS
DELIMITER ||
CREATE PROCEDURE INSERT_USUARIOS(IN USUARIO_N VARCHAR(15), IN BANCO VARCHAR(15), IN VALOR DECIMAL, IN FAMILIA_N INT)
BEGIN
	INSERT INTO USUARIOS VALUES (USUARIO_N,BANCO,VALOR,FAMILIA_N);
END ||
DELIMITER ;
CALL INSERT_USUARIOS("PRUEBA123", "56651-86516-EEE", 500.00, 1);

-- UPDATE : ACTUALIZA DATOS
DELIMITER ||
CREATE PROCEDURE UPDATE_USUARIOS(IN USUARIO_N VARCHAR(15), IN BANCO VARCHAR(15), IN VALOR_N DECIMAL)
BEGIN
	UPDATE USUARIOS SET CUENTA_BANCARIA = BANCO, VALOR = VALOR_N WHERE USUARIO = USUARIO_N;
END ||
DELIMITER ;
CALL UPDATE_USUARIOS("PRUEBA123", "56651-86516-EEE", 500.00);

-- DELETE : ELIMINA DATOS
DELIMITER ||
CREATE PROCEDURE DELETE_USUARIOS(IN USUARIO_N VARCHAR(15))
BEGIN
	DELETE FROM USUARIOS WHERE USUARIO = USUARIO_N;
END ||
DELIMITER ;
CALL DELETE_USUARIOS("PRUEBA");
