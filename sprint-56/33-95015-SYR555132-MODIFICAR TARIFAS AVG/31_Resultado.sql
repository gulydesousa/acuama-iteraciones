
SELECT T0.trfsrvcod, S.svcdes, S.svctipo, T0.trfcod, T0.trfdes, TV0.trvfecha, TV0.trvfechafin, TV0.trvcuota
, TV0.trvprecio1, TV0.trvprecio2, TV0.trvprecio3, TV0.trvprecio4, TV0.trvprecio5, TV0.trvprecio6, TV0.trvprecio7, TV0.trvprecio8, TV0.trvprecio9
, TV0.trvlegalavb
INTO #BAJAS
FROM Tarifas AS T0
INNER JOIN servicios AS S
ON T0.trfsrvcod = S.svccod
AND T0.trfFechaBaja='20240801' 
INNER JOIN dbo.tarval AS TV0
ON TV0.trvsrvcod = T0.trfsrvcod
AND TV0.trvtrfcod = T0.trfcod
AND trvfechafin = T0.trfFechaBaja

SELECT T0.trfsrvcod, S.svcdes, S.svctipo, T0.trfcod, T0.trfdes, TV0.trvfecha, TV0.trvfechafin, TV0.trvcuota
, TV0.trvprecio1, TV0.trvprecio2, TV0.trvprecio3, TV0.trvprecio4, TV0.trvprecio5, TV0.trvprecio6, TV0.trvprecio7, TV0.trvprecio8, TV0.trvprecio9
, TV0.trvlegalavb
INTO #ACTIVAS
FROM Tarifas AS T0
INNER JOIN dbo.tarval AS TV0
ON TV0.trvsrvcod = T0.trfsrvcod
AND TV0.trvtrfcod = T0.trfcod
AND (TV0.trvfechafin IS NULL OR trvfechafin>'20240802')
INNER JOIN servicios AS S
ON T0.trfsrvcod = S.svccod
WHERE T0.trfFechaBaja IS NULL OR T0.trfFechaBaja>'20240802'

SELECT A.*, B.trfcod, B.trfdes, B.trvfecha, B.trvfechafin
, B.trvcuota, B.trvprecio1, B.trvprecio2, B.trvprecio3, B.trvlegalavb
FROM #ACTIVAS AS A
LEFT JOIN #BAJAS AS B
ON B.trfsrvcod = A.trfsrvcod
AND B.trfcod = A.trfcod -1


--SELECT * FROM #BAJAS
--SELECT * FROM #ACTIVAS
DROP TABLE IF EXISTS #BAJAS;

DROP TABLE IF EXISTS #ACTIVAS;