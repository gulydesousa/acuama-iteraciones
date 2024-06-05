SELECT * FROM menu WHERE menutitulo_es LIKE '%boe%'


--DECLARE @urlEnvioBOE VARCHAR(250)= '~/Cobros/CR017_GeneracionOTCorte.aspx?tipo=1';
--DECLARE @urlDatosBOE VARCHAR(250)= '~/Cobros/CR0036_DatosBOE.aspx';
--DECLARE @urlEnvioNotiBOE VARCHAR(250)= '~/Catastro/CA014_EnvioNotificacionesBOE.aspx';

DECLARE @urlProcesoBOE VARCHAR(250)= '~/Catastro/CC072_ProcesoBOE.aspx';
DECLARE @cssProcesoBOE VARCHAR(250)= '~/Catastro/Css/ProcesoBOE.css';

DECLARE @urlCaratulaBOE VARCHAR(250)= '~/Catastro/CA016_CargaCaratulasBOE.aspx';
DECLARE @cssCaratulaBOE VARCHAR(250)= '~/Catastro/Css/cargacaratulasboe.css';


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

--Insertar Envío BOE
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlProcesoBOE AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Envío BOE', NULL, NULL, @urlProcesoBOE, @cssProcesoBOE,  NULL, NULL, 11, 1, 1)
	SET @menuID = @menuID+1; 
END


--Insertar Datos Fijos BOE
IF NOT EXISTS(SELECT 1  FROM menu  WHERE menuurl = @urlCaratulaBOE AND menupadre=@notificaciones)
BEGIN
	INSERT INTO menu VALUES(@menuID, @notificaciones, 'Datos Fijos BOE', NULL, NULL, @urlCaratulaBOE, @cssCaratulaBOE,  NULL, NULL, 12, 1, 1)
	SET @menuID = @menuID+1; 
END




SELECT * FROM menu WHERE menuid = @notificaciones
UNION
SELECT * FROM menu WHERE menupadre=@notificaciones



--SELECT * 
DELETE
FROM menu 
WHERE menuurl IN (@urlProcesoBOE, @urlCaratulaBOE)
AND menupadre <>@notificaciones AND menutitulo_es<>'Emisión de notific.';