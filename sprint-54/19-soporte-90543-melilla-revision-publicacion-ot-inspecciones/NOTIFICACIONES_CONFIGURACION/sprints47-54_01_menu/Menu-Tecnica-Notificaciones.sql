DECLARE @urlNotif VARCHAR(250)= '~/Catastro/CA013_EmisionNotificaciones.aspx';
DECLARE @cssNotif VARCHAR(250)= '~/Catastro/Css/emisionNotificaciones.css';


DECLARE @urlExcel VARCHAR(250)= '~/Sistema/BX203_VisorInformesExcelPerfil.aspx?menu=';
DECLARE @cssExcel VARCHAR(250)= '~/Sistema/Css/visorInformesExcelPerfil.css';

DECLARE @tecnica INT;
SELECT @tecnica = menuid FROM menu WHERE menutitulo_es='Técnica'


DECLARE @menuID INT;
SELECT @menuID = MAX(menuID) + 1 FROM menu;

--Insertar menu padre
DECLARE @notificaciones INT;
SELECT @notificaciones = menuid  FROM menu WHERE menupadre=@tecnica AND menutitulo_es = 'Notificaciones'

IF(@notificaciones IS NULL)
BEGIN
	INSERT INTO menu VALUES (@menuid, @tecnica, 'Notificaciones', 'Notificaciones de Inspección',NULL,NULL,NULL,NULL,NULL, 999, 1, 1)
	SET @notificaciones = @menuID;
	SET @menuID = @menuID+1; 
END

--Insertar Emision de notificaciones
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlNotif AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Emisión de notific.', 'Emisión de notificaciones', NULL, @urlNotif, @cssNotif,  NULL, NULL, 10, 1, 1)
	SET @menuID = @menuID+1; 
END

--Insertar Informes Excel
SET @urlExcel = CONCAT(@urlExcel, @notificaciones);
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlExcel AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Informes Excel', NULL, NULL, @urlExcel, @cssExcel,  NULL, NULL, 20, 1, 1)
	SET @menuID = @menuID+1; 
END

SELECT * FROM menu WHERE menuid = @notificaciones
UNION
SELECT * FROM menu WHERE menupadre=@notificaciones

DELETE
FROM menu 
WHERE menuurl IN (@urlNotif, @urlExcel)
AND menupadre <>@notificaciones  AND menutitulo_es<>'Emisión de notific.';



DECLARE @catastro INT;
SELECT @catastro = menuid FROM menu WHERE menutitulo_es='Catastro';
SELECT @menuID = MAX(menuID) + 1 FROM menu;

--Insertar Emision de notificaciones
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlNotif AND menupadre=@catastro)
BEGIN
	INSERT INTO menu VALUES(@menuID, @catastro, 'Emisión de notific.', 'Emisión de notificaciones', NULL, @urlNotif, @cssNotif,  NULL, NULL, 10, 1, 1)
	SET @menuID = @menuID+1; 
END


SELECT *
FROM menu 
WHERE  menutitulo_es='Emisión de notific.';



