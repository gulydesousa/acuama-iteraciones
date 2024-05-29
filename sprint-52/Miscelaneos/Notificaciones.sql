--TABLA QUE ENLAZA LA EMISION CON LAS OT DE INSPECCION
SELECT *  FROM otInspeccionesNotificacionEmisiones_Melilla ORDER By otineCtrCod
--DELETE  FROM otInspeccionesNotificacionEmisiones_Melilla

--DATOS QUE SE USAN PARA MONTAR LA NOTIFICACION EN REPORTING
--Data para cada carta de notificaciones
--TRUNCATE TABLE ReportingServices.TO039_EmisionNotificaciones_Notificaciones
SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones

--PARAMETROS
--DELETE  FROM  [ReportingServices].[TO039_EmisionNotificaciones_Emisiones]
SELECT * FROM  [ReportingServices].[TO039_EmisionNotificaciones_Emisiones]

/*
DELETE  FROM otInspeccionesNotificacionEmisiones_Melilla
TRUNCATE TABLE ReportingServices.TO039_EmisionNotificaciones_Notificaciones
DELETE  FROM  [ReportingServices].[TO039_EmisionNotificaciones_Emisiones]
*/

EXEC ReportingServices.TO040_EmisionPegatinas_Melilla 87
RETURN


SELECT C.* FROM otInspeccionesNotificacionEmisiones_Melilla AS E
INNER JOIN vContratosUltimaVersion AS C
ON C.ctrCod = E.otineCtrCod
ORDER BY C.ctrzoncod

SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser='gmdesousa'


SELECT ISNUMERIC(ctrRuta1) FROM contratos WHERE ctrcod=1841

SELECT * FROM parametros


 DECLARE	 @apto BIT = 1,
	@excluirNoEmision BIT = 0,
	@contratoD INT = 5339,
	@contratoH INT = 5339,
	@zonaD VARCHAR(4) = NULL,
	@zonaH VARCHAR(4) = NULL,
	--Se filtra por la ruta en las inspecciones
	@ruta1D VARCHAR(10) = NULL,
	@ruta1H VARCHAR(10) = NULL,
	@ruta2D VARCHAR(10) = NULL,
	@ruta2H VARCHAR(10) = NULL,
	@ruta3D VARCHAR(10) = NULL,
	@ruta3H VARCHAR(10) = NULL,
	@ruta4D VARCHAR(10) = NULL,
	@ruta4H VARCHAR(10) = NULL,
	@ruta5D VARCHAR(10) = NULL,
	@ruta5H VARCHAR(10) = NULL,
	@ruta6D VARCHAR(10) = NULL,
	@ruta6H VARCHAR(10) = NULL,
-- Si es un listado: En este SP no hacemos nada en particular.
	@listado BIT = NULL,		 
-- Representante legal(Si, No, Indiferente) | Si tiene representante legal debe sacar dos cartas
	@legal VARCHAR(20) = NULL,	 
	@tieneEmail BIT = NULL,		
-- BATERIAS, CONTADORES
	@servicio VARCHAR(25) = NULL, 
-- Orden para los registros
	@orden VARCHAR(20) = NULL	  	
-- ******************************************
-- Si envias un usuario, se hacen todos los cálculos para crear una nueva emision
	, @usuario VARCHAR(10) = 'gmdesousa'

	DECLARE @id INT;
	DECLARE @numNotificaciones INT;
	DECLARE @fechaEmision DATETIME;

	EXEC @id = [ReportingServices].[TO039_Inspecciones_Melilla_Emision] @apto, @excluirNoEmision, @contratoD, @contratoH, @zonaD, @zonaH 
	, @ruta1D, @ruta1H, @ruta2D, @ruta2H, @ruta3D, @ruta3H, @ruta4D, @ruta4H, @ruta5D, @ruta5H, @ruta6D, @ruta6H
	, @listado, @legal, @tieneEmail, @servicio, @orden, @usuario, @fechaEmision OUTPUT, @numNotificaciones  OUTPUT;

	SELECT [@id] = @id, [@emisionFecha] = @fechaEmision;

 
--DELETE FROM ordenTrabajo  WHERE otdessolicitud='11389'
--SELECT * FROM ordenTrabajo  WHERE otdessolicitud='11389'
--DELETE FROM otInspecciones_Melilla WHERE objectid=11389
--UPDATE ordenTrabajo SET otfcierre=NULL WHERE otdessolicitud='11389'

SELECT * 
--DELETE 
FROM Task_Schedule WHERE tskUser='gmdesousa'
