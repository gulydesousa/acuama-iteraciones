DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240726';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf) ;



SELECT *
FROM [AVG].Tarifas AS T
LEFT JOIN dbo.servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod 
AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaFinTrf)
AND ISNULL(V.MM, 0) = ISNULL(T.Calibre, 0)
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaFinTrf);


SELECT * FROM servicios
SELECT * FROM tarval WHERE trvfechafin IS NULL AND trvprecio1=0.17
SELECT * FROM tarifas WHERE trfsrvcod=4 and trfcod IN (10103, 10104)


SELECT * FROM tarval WHERE trvfechafin IS NULL AND trvprecio1=0.44
SELECT * FROM tarval WHERE trvfechafin IS NULL AND trvprecio1=0.48