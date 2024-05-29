
--EXEC [dbo].[OrdenTrabajoZonasCambioContador_Select] @usuario='dmartin'
--EXEC [dbo].[OrdenTrabajoZonasCambioContador_Select] @usuario='msola'
--EXEC [dbo].[OrdenTrabajoZonasCambioContador_Select] @usuario='esaavedra'
--SELECT * FROM usuarios

CREATE PROCEDURE [dbo].[OrdenTrabajoZonasCambioContador_Select] 
	@usuario VARCHAR(10) = NULL,
	@zona VARCHAR(4) = NULL,
	@rechazadas BIT = NULL,
	@startIndex INT = 0,
	@pageSize INT = 100000000
AS SET NOCOUNT ON;
BEGIN
	DECLARE @tipoOtCC VARCHAR(4), @asignacionOtCC INT = 1, @esInspector BIT = 0;

	--[01]Parametros
	SELECT @tipoOtCC = pgsValor FROM parametros WHERE pgsClave = 'OT_TIPO_CC';
	SELECT @asignacionOtCC = ISNULL(pgsValor, 1) FROM parametros WHERE pgsClave = 'OTCC_ASIGNACION_OT';
	
	--[02]@esInspector
	IF (@usuario IS NOT NULL) 
	BEGIN
		SELECT @esInspector = E.eplInspector
		FROM dbo.empleados AS E
		INNER JOIN dbo.usuarios AS U 
		ON  U.usreplcod = eplcod
		AND U.usreplcttcod = E.eplcttcod
		AND U.usrcod = @usuario;
	END
	
	--[03]@ots: Ordenes de trabajo que pasan los filtos
	DECLARE @ots AS TABLE(otserscd SMALLINT, otsercod SMALLINT, otnum INT
	, direccion VARCHAR(200), zona VARCHAR(4), ruta VARCHAR(100)
	, contratista SMALLINT, empleado SMALLINT)
	
	--[04]Selecccionamos la PK de las OTs que cumplen los filtros
	INSERT INTO @ots(otserscd, otsercod, otnum
	--Incluimos otras columnas necesarias para la ordenación de los resultados
	, direccion, zona, ruta
	--Datos del contratista, empleado asociado al usuario que ha hecho la solicitud
	, contratista, empleado)

	SELECT otserscd, otsercod, otnum
	, direccion= ISNULL(OT.otdireccion, I.inmDireccion)
	, zona = C.ctrzoncod
	, ruta = CONCAT(
				RIGHT(REPLICATE('0',10) + ISNULL(ctrRuta1,''), 10), '.',
				RIGHT(REPLICATE('0',10) + ISNULL(ctrRuta2,''), 10), '.',
				RIGHT(REPLICATE('0',10) + ISNULL(ctrRuta3,''), 10), '.',
				RIGHT(REPLICATE('0',10) + ISNULL(ctrRuta4,''), 10), '.',
				RIGHT(REPLICATE('0',10) + ISNULL(ctrRuta5,''), 10), '.',
				RIGHT(REPLICATE('0',10) + ISNULL(ctrRuta6,''), 10))
	, contratista = U.usreplcttcod
	, empleado = U.usreplcod
	FROM dbo.ordenTrabajo AS OT
	INNER JOIN dbo.contratos AS C 
	ON OT.otCtrCod = C.ctrcod AND OT.otCtrVersion = ctrversion
	INNER JOIN dbo.inmuebles AS I 
	ON C.ctrinmcod = I.inmcod
	LEFT JOIN dbo.contadorCambio AS CC 
	ON CC.conCamOtNum = OT.otnum
	LEFT JOIN dbo.usuarios AS U 
	ON U.usrcod = OT.otUsuSolicitud
	
	WHERE OT.otottcod = @tipoOtCC
	AND (OT.otfcierre IS NULL)
	AND (OT.otfrealizacion IS NULL)
	AND (CC.conCamOtNum IS NULL) --Sin cambio de contador
	AND (@zona IS NULL OR ctrzoncod = @zona)
	AND (@rechazadas IS NULL OR (@rechazadas = 0 AND OT.otFecRechazo IS NULL) OR (@rechazadas = 1 AND OT.otFecRechazo IS NOT NULL))
	AND (OT.otPteRealizar IS NULL OR OT.otPteRealizar = 0);
	
	--[99]Resultado
	SELECT OT.otserscd, OT.otsercod, OT.otnum
		, OT.otfsolicitud
		, OT.otdessolicitud
		, OT.otFecRechazo
		, OT.otPrioridad
		, OT.otCtrCod
		, OT.otPteRealizar
		, OT.otCausaNoRealizacionCod
		, OT.otComentarioNoRealizacion
		, otdireccion=T.direccion
		--, zona
	FROM dbo.ordenTrabajo AS OT
	INNER JOIN @ots AS T
	ON OT.otsercod = T.otsercod
	AND OT.otserscd = T.otserscd
	AND OT.otnum = T.otnum
	LEFT JOIN dbo.usuarios AS U
	ON (@usuario IS NOT NULL AND U.usrcod = @usuario)
	WHERE @usuario IS NULL 
	OR @esInspector = 1 
	--[OTCC_ASIGNACION_OT=1] Podrá ver todas las OT
	OR  @asignacionOtCC = 1 
	--[OTCC_ASIGNACION_OT=2] Filtra por usuario y contratista
	--Podrá ver solo las OT asociadas al empleado+contratista
	OR (@asignacionOtCC = 2 AND OT.otEplCttCod= U.usreplcttcod AND OT.otEplCod = U.usreplcod)
	OR (@asignacionOtCC = 2 AND OT.otTipoOrigen='CCCSV' AND T.contratista= U.usreplcttcod AND T.empleado = U.usreplcod )
	--[OTCC_ASIGNACION_OT=3] Filtra por contratista	
	--podrá ver solo las OT asociadas al contratista
	OR (@asignacionOtCC = 3 AND OT.otEplCttCod= U.usreplcttcod) 
	OR (@asignacionOtCC = 3 AND OT.otTipoOrigen='CCCSV' AND T.contratista= U.usreplcttcod)
	ORDER BY T.zona, OT.otPrioridad, T.ruta

	OFFSET @startIndex ROWS  
    FETCH NEXT @pageSize ROWS ONLY
END
GO


