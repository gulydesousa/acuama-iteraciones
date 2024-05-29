--PRUEBA CON_ANOMALIA: 10026
--PRUEBA SIN ANOMALIA: 16258-16764
-- Tipo Incidencia: Lectura, Inspeccion
-- OT con anomalía(apto = false)
-- OT sin anomalía (apto = true)
/*
  DECLARE	 @apto BIT = 0,
	@excluirNoEmision BIT = 0,
	@contratoD INT = 10020,
	@contratoH INT = 10033,
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

*/
ALTER PROCEDURE [ReportingServices].[TO039_Inspecciones_Melilla_Emision]
	@apto BIT,
	@excluirNoEmision BIT = 0,
	@contratoD INT = NULL,
	@contratoH INT = NULL,
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
-- Envias un usuario y se hacen todos los cálculos para crear una nueva emision
	, @usuario VARCHAR(10) 
	, @fechaEmision DATETIME OUTPUT
	, @numNotificaciones INT OUTPUT
AS

SET NOCOUNT ON;

-- Tipo Incidencia: Lectura, Inspeccion
-- OT con anomalía(apto = false)
-- OT sin anomalía (apto = true)

DECLARE @tipo VARCHAR(20)= IIF(@apto=1, 'OT sin anomalía', 'OT con anomalía');

-- No envias un id de emision, se calculan los datos para las emisiones
DECLARE @idEmision INT = 0;

--*****************************************
--[06] Emisión si se envia el id de usuario
--*****************************************
IF @usuario IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.usuarios WHERE usrcod = @usuario)
	RETURN @idEmision;

BEGIN TRY	
	DECLARE @spName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @fechaEmsion DATETIME;
	
	BEGIN TRAN

	DECLARE @fecha DATETIME;
		
	--***************************************
	--[06.1] Insertamos los parametros de esta llamada, los filtos de la emision
	EXEC @idEmision = [ReportingServices].[TO039_EmisionNotificaciones_Emisiones_Insert]
	  @apto
	, @tipo
	, @excluirNoEmision
	, @contratoD, @contratoH
	, @zonaD, @zonaH
	, @ruta1D, @ruta1H, @ruta2D, @ruta2H, @ruta3D, @ruta3H, @ruta4D, @ruta4H, @ruta5D, @ruta5H, @ruta6D, @ruta6H
	, @listado, @legal, @tieneEmail, @servicio
	, @orden
	, @usuario
	, @fechaEmision OUTPUT;

	--SELECT @idEmision;

	--***************************************
	--[06.2] Insertamos en la tabla para los informes
	SELECT * 
	INTO #NOTIFICACIONES
	FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
	WHERE emisionID = -1;
	
	INSERT INTO #NOTIFICACIONES
	--Con el parametro @idEmision=0 conseguimos que el select nos traiga los datos para las cartas
	EXEC [ReportingServices].[TO039_Inspecciones_Melilla] @tipo, @excluirNoEmision, @contratoD, @contratoH, @zonaD, @zonaH 
	, @ruta1D, @ruta1H, @ruta2D, @ruta2H, @ruta3D, @ruta3H, @ruta4D, @ruta4H, @ruta5D, @ruta5H, @ruta6D, @ruta6H
	, @listado, @legal, @tieneEmail, @servicio, @orden, 0;
	
	--SELECT * FROM #NOTIFICACIONES;

	--***************************************
	--[06.3] Contamos el numero de notificaciones emitidas
	--Si no hay datos no se registra la emisión
	SET @numNotificaciones = @@ROWCOUNT;
	IF (@numNotificaciones=0) THROW 50000, 'No hay registros para la notificación', 1;

	--***************************************
	--[06.4]Asignemos el id de la emision a los nuevos resultados
	UPDATE #NOTIFICACIONES SET emisionID = @idEmision 
	
	--[06.4]Insertamos las notificaciones con el ID de emisión
	INSERT INTO ReportingServices.TO039_EmisionNotificaciones_Notificaciones
	SELECT * FROM #NOTIFICACIONES;

	--***************************************
	--[06.5] Insertamos en el registro de notificaciones
    INSERT INTO dbo.otInspeccionesNotificacionEmisiones_Melilla 
    SELECT [otineObjectID] = [objectid]
		 , [otineCtrCod] = [CONTRATO]	
		 , [otineOtserscd] = [otSociedad]
		 , [otineOtsercod] = [otSerie]
		 , [otineOtnum] = [otNum]		
		 , [otineEmision]= @idEmision
		 , [otineTitCod] = USUARIOCOD
		 , [otineCtrRepresent] = CLI_REPRESENTANTE		
		 , [otineEmisionEstado] = [emisionEstado]
		 , [otineObservaciones] = @spName
    FROM #NOTIFICACIONES 
	WHERE emisionID = @idEmision;

	--***************************************
	--[06.4] Enviar la tarea de las pegatinas	
	--EXEC [dbo].[Task_Schedule_EmisionPegatinas] @idEmision; 
	
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	--ROLLBACK TRANSACTION si hay un error
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION;
		SET @idEmision = -1;
		THROW;
	END 
END CATCH

IF OBJECT_ID('tempdb..#NOTIFICACIONES') IS NOT NULL DROP TABLE #NOTIFICACIONES;

--*****************************************
-- [99] RETURN: Gestiona el retorno del ID de la emisión. 
--    > El ID específico de la emisión si la operación es exitosa.
--    > 0 si no se ha registrado ninguna emisión.
--    > -1 en caso de que se encuentre con un error durante la operación.
--*****************************************
RETURN  @idEmision;

GO
