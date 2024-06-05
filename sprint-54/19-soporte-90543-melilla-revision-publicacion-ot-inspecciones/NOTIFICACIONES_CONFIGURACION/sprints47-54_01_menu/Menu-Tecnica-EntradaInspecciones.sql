DECLARE @urlEntrada VARCHAR(250)= '~/Almacen/TO039_OtInspeccionesMasivas.aspx';
DECLARE @cssEntrada VARCHAR(250) ='~/Almacen/Css/otInspeccionesMasivas.css'

DECLARE @urlFicheros VARCHAR(250)= '~/Almacen/TO041_OtInspeccionesFicheros.aspx';
DECLARE @cssFicheros VARCHAR(250)= '~/Almacen/Css/otInspeccionesMasivas.css';

DECLARE @urlValidaciones VARCHAR(250)= '~/Almacen/TO040_OtInspeccionesValidaciones.aspx';
DECLARE @cssValidaciones VARCHAR(250)= '~/Almacen/Css/otInspeccionesValidaciones.css';

--SELECT * FROM MENU WHERE menutitulo_es='Entrada OT Inspecciones'

DECLARE @tecnica INT;
SELECT @tecnica = menuid FROM menu WHERE menutitulo_es='Técnica'


DECLARE @menuID INT;
SELECT @menuID = MAX(menuID) + 1 FROM menu;

--Insertar menu padre
DECLARE @notificaciones INT;
SELECT @notificaciones = menuid  FROM menu WHERE menupadre=@tecnica AND menutitulo_es = 'Notificaciones'

IF(@notificaciones IS NULL)
BEGIN
	INSERT INTO menu VALUES (@menuid, @tecnica, 'Notificaciones', NULL,NULL,NULL,NULL,NULL,NULL, 999, 1, 1)
	SET @notificaciones = @menuID;
	SET @menuID = @menuID+1; 
END

--Insertar Entrada OT Inspecciones
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlEntrada AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Entrada OT Inspecciones', NULL, NULL, @urlEntrada, @cssEntrada,  NULL, NULL, 1, 1, 1)
	SET @menuID = @menuID+1; 
END


--Insertar Ficheros OT Inspecciones
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlFicheros AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Ficheros OT Inspecciones', NULL, NULL, @urlFicheros, @cssFicheros,  NULL, NULL, 2, 1, 1)
	SET @menuID = @menuID+1; 
END


--Insertar Ficheros OT Inspecciones
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlValidaciones AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Insp. Validaciones', 'Inspecciones Validaciones', NULL, @urlValidaciones, @cssValidaciones,  NULL, NULL, 30, 1, 1)
	SET @menuID = @menuID+1; 
END



SELECT * FROM menu WHERE menuid = @notificaciones
UNION
SELECT * FROM menu WHERE menupadre=@notificaciones


--SELECT * 
DELETE
FROM menu 
WHERE menuurl IN (@urlEntrada, @urlFicheros, @urlValidaciones)
AND menupadre <>@notificaciones  AND menutitulo_es<>'Emisión de notific.';

