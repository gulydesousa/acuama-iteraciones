DECLARE	@return_value int
EXEC	@return_value = [dbo].[ZonasOtCambioContador_Select]
		@usuario = N'esaavedra'
SELECT	'Return Value' = @return_value
 
DECLARE	@return_value int
EXEC	@return_value = [dbo].[OrdenTrabajoZonasCambioContador_Select]
		@usuario = N'esaavedra',
		@zona = N'4'
SELECT	'Return Value' = @return_value


EXEC [dbo].[OrdenTrabajoZonasCambioContador_Select] @usuario='jruperti'
EXEC ZonasOtCambioContador_Select 'jruperti'

SELECT *
FROM dbo.empleados AS E
		INNER JOIN dbo.usuarios AS U 
		ON  U.usreplcod = eplcod
		AND U.usreplcttcod = E.eplcttcod
		AND U.usrcod = 'jruperti';

SELECT *
FROM empleados
		INNER JOIN usuarios ON usreplcod = eplcod AND usrcod = 'esaavedra' AND U.usreplcttcod = E.eplcttcod


SELECT * FROM contadorCambio WHERE conCamOtNum IN (27937,28012,28247)

SELECT * FROM contadorCambio WHERE conCamOtNum IN (28099,28334)


select otTipoOrigen, * from ordentrabajo where otnum in (27937,28012,28099,28247,28334)