--DROP PROCEDURE [ReportingServices].[TO040_EmisionPegatinas]
/*
DECLARE  @idEmision INT = 4

EXEC [ReportingServices].[TO040_EmisionPegatinas_Melilla] @idEmision;
*/

ALTER PROCEDURE [ReportingServices].[TO040_EmisionPegatinas_Melilla]
  @idEmision INT
AS
	
	SELECT INMUEBLE, FISDIR1 , FISNOM, CONTRATO
	, emisionEstado	
	, emisionID
	, RN
	, ID= FORMAT(EmisionID, 'D4') + '-' + FORMAT(ISNULL(RN, 0), 'D6')
	, [D] = [otNum] 
	, [X] = CEILING (CAST(RN AS FLOAT)/3)
	, [C] = IIF(RN%3=0, 3, RN%3) 
	, [F] = CAST(CEILING (CAST(RN AS FLOAT)/3) AS INT) 
	FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
	WHERE emisionID = @idEmision 
	ORDER BY RN;
GO


