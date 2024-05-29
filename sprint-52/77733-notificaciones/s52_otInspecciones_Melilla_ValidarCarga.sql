/*
DECLARE @objectID INT =11388;
DECLARE @ctrCod INT =3290;

EXEC otInspecciones_Melilla_ValidarCarga @objectID, @ctrCod

*/

ALTER PROCEDURE otInspecciones_Melilla_ValidarCarga 
@objectID INT, @ctrCod INT
AS
	DECLARE @RESULT AS TABLE(mensaje VARCHAR(250))
	
	--No es posible recargar si ya hay una emisión
	DECLARE @idEmision INT;

	SELECT @idEmision = MAX(E.otineEmision) 
	FROM otInspeccionesNotificacionEmisiones_Melilla AS E
	WHERE otineObjectID=@objectID AND otineCtrCod=@ctrCod;
	
	--SELECT @idEmision
	
	IF (@idEmision IS NOT NULL)
		INSERT INTO @RESULT
		SELECT CONCAT ('No es posible actualizar los datos. La Notificación ya está emitida para esta Inspección (', 
		'IdEmision: ', E.emisionID,
		', Fecha: ', E.fecha,
		', Usuario: ' , E.usuario,
	
		')') FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones AS E 
		WHERE emisionID=@idEmision;
	
	--Retornamos todos los mensajes que incumplan las restricciones de Inspecciones
	SELECT * FROM @RESULT;

GO