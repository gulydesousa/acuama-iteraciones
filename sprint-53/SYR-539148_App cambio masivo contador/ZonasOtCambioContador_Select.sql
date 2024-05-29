--DECLARE @usuario VARCHAR(10) = 'esaavedra'

ALTER PROCEDURE [dbo].[ZonasOtCambioContador_Select] 
	@usuario VARCHAR(10) = NULL
AS SET NOCOUNT ON;

BEGIN
	DECLARE @tipoOtCC VARCHAR(4), @asignacionOtCC INT = 1, @esInspector BIT = 0;
	SELECT @tipoOtCC = pgsValor FROM parametros WHERE pgsClave = 'OT_TIPO_CC';
	SELECT @asignacionOtCC = ISNULL(pgsValor, 1) FROM parametros WHERE pgsClave = 'OTCC_ASIGNACION_OT';
	
	IF (@usuario IS NOT NULL) 
	BEGIN
		SELECT @esInspector = E.eplInspector
		FROM dbo.empleados AS E
		INNER JOIN dbo.usuarios AS U 
		ON  U.usreplcod = eplcod
		AND U.usreplcttcod = E.eplcttcod
		AND U.usrcod = @usuario;
	END

	SELECT zoncod, zondes, COUNT(otnum) otAbiertas
	FROM zonas
	INNER JOIN contratos ON zoncod = ctrzoncod
	INNER JOIN ordenTrabajo ON otCtrCod = ctrcod AND otCtrVersion = ctrversion
	LEFT JOIN contadorCambio ON conCamOtNum = otnum
	WHERE otottcod = @tipoOtCC
		AND otfcierre IS NULL 
		AND otfrealizacion IS NULL
		AND (otPteRealizar IS NULL OR otPteRealizar = 0)
		AND conCamOtNum IS NULL
		AND (@esInspector = 1 OR @usuario IS NULL OR @asignacionOtCC = 1
			OR (@asignacionOtCC = 2 AND @usuario IS NOT NULL AND (otEplCod = (SELECT usreplcod FROM usuarios WHERE usrcod = @usuario) 
				AND otEplCttCod = (SELECT usreplcttcod FROM usuarios WHERE usrcod = @usuario)))
			OR (@asignacionOtCC = 3 AND @usuario IS NOT NULL AND otEplCttCod = (SELECT usreplcttcod FROM usuarios WHERE usrcod = @usuario))
		)
	GROUP BY zoncod, zondes
END
GO


