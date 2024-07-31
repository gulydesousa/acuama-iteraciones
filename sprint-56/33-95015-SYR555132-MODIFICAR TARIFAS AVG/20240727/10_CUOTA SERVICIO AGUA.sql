DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fecha DATE = '20240726';
DECLARE @fechaInicio DATE = '20240802';

--[00]Creamos una tabla temporal con los campos clave de lo que vamos a actualizar
SELECT TT.trfsrvcod, TT.trfcod
, TV.trvfecha, TV.trvcuota
, T.Servicio
, T.calibre
, [xlsTrvCuota] = ROUND(T.trvCuota, 2)
, T.trvCuota_2024
--La cuota actual del excel es la misma que la de la tabla
, DatosOK = IIF(TV.trvcuota-ROUND(T.trvCuota, 2) = 0, 1, 0)
FROM [AVG].Tarifas AS T
LEFT JOIN dbo.servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod 
AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaInicio)
AND V.MM = CONCAT(T.Calibre, 'MM')
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaInicio)



--CUOTA SERVICIO AGUA
--[01]Asignarle fecha baja a la tarifa anterior
SELECT TT.trfcod, TT.trfsrvcod, TT.trfFechaBaja, TT.trfUsrBaja
FROM [AVG].Tarifas AS T
LEFT JOIN dbo.servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaInicio)
AND V.MM = CONCAT(T.Calibre, 'MM')
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaInicio)

--[02] Asignar fecha baja a los valores de tarifa
SELECT TV.trvsrvcod, TV.trvtrfcod, TV.trvfechafin, TV.trvcuota
, T.calibre
, T.Servicio
FROM [AVG].Tarifas AS T
LEFT JOIN servicios AS S
ON S.svcdes = T.Servicio
LEFT JOIN  [AVG].vTarifas AS V
ON V.trfsrvcod= S.svccod AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaInicio)
AND V.MM = CONCAT(T.Calibre, 'MM')
LEFT JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = S.svccod
AND TT.trfcod = V.trfcod
LEFT JOIN dbo.tarval AS TV
ON TV.trvsrvcod=S.svccod
AND TV.trvtrfcod = V.trfcod
AND (TV.trvfechafin IS NULL OR TV.trvfechafin>@fechaInicio)




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


