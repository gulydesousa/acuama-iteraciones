--[01]Cuotas: 17 filas en el excel
--Actualicemos la tarifa y el servicio
DECLARE @fechaFinTrf DATE = '20240801';

UPDATE T SET ServicioCod= S.svccod, TarifaCod=TT.trfcod
OUTPUT INSERTED.*
FROM [AVG].Tarifas AS T
INNER JOIN dbo.servicios AS S
ON S.svcdes = T.Servicio
AND T.trvCuota IS NOT NULL
INNER JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod 
AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaFinTrf)
AND ISNULL(V.MM, 0) = ISNULL(T.Calibre, 0)
INNER JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
INNER JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaFinTrf)
AND (ROUND(T.trvCuota, 2) = TV.trvCuota);


--[02]Precios: 00 tarifas de consumo
--Actualicemos las tarifas de consumo
UPDATE T SET ServicioCod= S.svccod
OUTPUT INSERTED.*
FROM [AVG].Tarifas AS T
INNER JOIN dbo.servicios AS S
ON S.svcdes = T.Servicio
AND T.trvCuota IS NULL
INNER JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = T.TarifaCod
INNER JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = T.TarifaCod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaFinTrf)
AND (T.trvprecio1 = TV.trvprecio1)
AND (T.trvprecio2 IS NULL OR  T.trvprecio2= TV.trvprecio2)
AND (T.trvprecio3 IS NULL OR  T.trvprecio3= TV.trvprecio3);
GO

SELECT * FROM [AVG].Tarifas ORDER BY ServicioCod, TarifaCod