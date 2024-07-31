DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240726';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf) ;


--[00]Creamos una tabla temporal con los campos clave de lo que vamos a actualizar
SELECT TT.trfsrvcod, TT.trfcod, TT.trfFechaBaja, TT.trfFecUltMod
, TV.trvfecha, TV.trvcuota, TV.trvfechafin
, V.Tarifa
, T.Servicio
, T.calibre
, [xlsTrvCuota] = ROUND(T.trvCuota, 2)
, T.trvCuota_2024
--La cuota actual del excel es la misma que la de la tabla
, DatosOK = IIF(TV.trvcuota-ROUND(T.trvCuota, 2) = 0, 1, 0)
INTO #KEYS
FROM [AVG].Tarifas AS T
LEFT JOIN dbo.servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod 
AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaFinTrf)
AND V.MM = CONCAT(T.Calibre, 'MM')
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaFinTrf);

IF EXISTS(SELECT 1 FROM #KEYS WHERE DatosOK = 0)
BEGIN
	DROP TABLE IF EXISTS #KEYS;
	RETURN
END

SELECT * FROM #KEYS;


--[10]Seleccionamos las tarifas y los valores que debemos dar de baja
SELECT T.*
--UPDATE T SET TT.trfFechaBaja=@fechaFinTrf, TT.trfUsrBaja=@usuario, trfFecUltMod=@fecha,trfUsrUltMod=@usuario
INTO [AVG].TarifasBaja
FROM dbo.tarifas AS T
INNER JOIN #KEYS AS K
ON T.trfsrvcod = K.trfsrvcod
AND T.trfcod = K.trfcod;

SELECT TV.*
--UPDATE TV SET TV.trvfechafin = @fechaFinTrf
INTO [AVG].TarvalBaja
FROM dbo.tarval AS TV
INNER JOIN #KEYS AS K
ON TV.trvsrvcod = K.trfsrvcod
AND TV.trvtrfcod = K.trfcod
AND TV.trvfecha = K.trvfecha;

--[20]Seleccionamos las tarifas y los valores que vamos a dar de alta
SELECT TT.[trfsrvcod]
, [trfcod] = TT.trfcod+1
, [trfdes] = CONCAT(K.Tarifa, ' - BOP 137 (17-07-2024)')
, TT.trfescala1, TT.trfescala2, TT.trfescala3, TT.trfescala4, TT.trfescala5, TT.trfescala6, TT.trfescala7, TT.trfescala8, TT.trfescala9
, TT.trfpromedio
, TT.trfFechaBaja, TT.trfUsrBaja
, TT.trfctacon
, TT.trfUdsPorEsc, TT.trfUdsPorPrecio, TT.trfBonificable
, TT.trfFecUltMod, TT.trfUsrUltMod
, [trfFecReg] = @fechaReg
, [trfUsrReg] = @usuario
, TT.trfCodDesglose
, TT.trfCB
, TT.trfAplicarEscMax
, TT.trfAplicarEscMin
, [trfconDiametro] = K.calibre
, TT.trfconTeleLectura
INTO [AVG].TarifasAlta
FROM dbo.tarifas AS TT
INNER JOIN #KEYS AS K
ON TT.trfsrvcod = K.trfsrvcod
AND TT.trfcod = K.trfcod;



SELECT [trvsrvcod] = TV.trvsrvcod
, [trvtrfcod] = TV.trvtrfcod + 1
, [trvfecha] = @fechaIniTrf
, [trvfechafin]=NULL
, [trvCuota] = ROUND(K.trvCuota_2024, 2)
, TV.trvprecio1, TV.trvprecio2, TV.trvprecio3, TV.trvprecio4, TV.trvprecio5, TV.trvprecio6, TV.trvprecio7, TV.trvprecio8, TV.trvprecio9
, [trvlegalavb] = 'BOP N. 137(17-07-2024)'
, TV.trvlegal
, TV.trvumdcod
, K.calibre
, K.Servicio
INTO [AVG].TarvalAlta
FROM dbo.tarval AS TV
INNER JOIN #KEYS AS K
ON TV.trvsrvcod = K.trfsrvcod
AND TV.trvtrfcod = K.trfcod
AND TV.trvfecha = K.trvfecha;


SELECT * FROM [AVG].TarifasBaja;
SELECT * FROM [AVG].TarifasAlta;

SELECT * FROM [AVG].TarvalBaja;
SELECT * FROM [AVG].TarvalAlta;


DROP TABLE IF EXISTS #KEYS;

DROP TABLE IF EXISTS [AVG].TarifasBaja;
DROP TABLE IF EXISTS [AVG].TarifasAlta;
DROP TABLE IF EXISTS [AVG].TarvalBaja;
DROP TABLE IF EXISTS [AVG].TarvalAlta;

/*




--[11] Insertar nuevas tarifas
SELECT [trfsrvcod] = S.svccod
, [trfcod] = TT.trfcod+1
, [trfdes] = CONCAT(V.Tarifa, ' - BOP 137 (17-07-2024)')
, TT.trfescala1, TT.trfescala2, TT.trfescala3, TT.trfescala4, TT.trfescala5, TT.trfescala6, TT.trfescala7, TT.trfescala8, TT.trfescala9
, TT.trfpromedio
, TT.trfFechaBaja, TT.trfUsrBaja
, TT.trfctacon
, TT.trfUdsPorEsc, TT.trfUdsPorPrecio, TT.trfBonificable
, TT.trfFecUltMod, TT.trfUsrUltMod
, [trfFecReg] = @fecha
, [trfUsrReg] = @usuario
, TT.trfCodDesglose
, TT.trfCB
, TT.trfAplicarEscMax
, TT.trfAplicarEscMin
, [trfconDiametro] = T.calibre
, TT.trfconTeleLectura
FROM [AVG].Tarifas AS T
LEFT JOIN servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod AND (trfFechaBaja IS NULL OR trfFechaBaja> @fechaInicio)
AND V.MM = CONCAT(T.Calibre, 'MM')
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaInicio)


--[12] Insertar nuevos valores de tarifa
SELECT TV.trvsrvcod
, [trvsrvcod] = TV.trvsrvcod
, [trvtrfcod] = TV.trvtrfcod + 1
, [trvfecha] = @fechaInicio
, [trvfechafin]=NULL
, [trvCuota] = ROUND(T.trvCuota_2024, 2)
, TV.trvprecio1, TV.trvprecio2, TV.trvprecio3, TV.trvprecio4, TV.trvprecio5, TV.trvprecio6, TV.trvprecio7, TV.trvprecio8, TV.trvprecio9
, [trvlegalavb] = 'BOP N. 137(17-07-2024)'
, TV.trvlegal
, TV.trvumdcod
, T.calibre
, T.Servicio
FROM [AVG].Tarifas AS T
LEFT JOIN servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod AND (trfFechaBaja IS NULL OR trfFechaBaja> @fechaInicio)
AND V.MM = CONCAT(T.Calibre, 'MM')
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaInicio)


*/