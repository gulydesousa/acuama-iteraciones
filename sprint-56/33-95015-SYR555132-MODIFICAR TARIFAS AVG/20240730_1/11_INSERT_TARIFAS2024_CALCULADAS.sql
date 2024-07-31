BEGIN TRAN

--Tarifas que Margari tiene que calcular con un excel
DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240730';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf);


--****************************************
--Insertamos nuevas tarifas calculadas por margari
INSERT INTO dbo.tarifas  OUTPUT INSERTED.*
SELECT T.[trfsrvcod]
, [trfcod] = T.trfcod+1
, [trfdes] =CONCAT(IIF(CHARINDEX(' - ', trfdes)=0, trfdes, LEFT(trfdes, CHARINDEX(' - ', trfdes) - 1)),' - BOP 137 (17-07-2024)')
, T.trfescala1, T.trfescala2, T.trfescala3, T.trfescala4, T.trfescala5, T.trfescala6, T.trfescala7, T.trfescala8, T.trfescala9
, T.trfpromedio
, [trfFechaBaja] = NULL
, trfUsrBaja = NULL
, T.trfctacon
, T.trfUdsPorEsc, T.trfUdsPorPrecio, T.trfBonificable
, trfFecUltMod = NULL
, trfUsrUltMod = NULL
, [trfFecReg] = @fechaReg
, [trfUsrReg] = @usuario
, T.trfCodDesglose
, T.trfCB
, T.trfAplicarEscMax
, T.trfAplicarEscMin
, T.[trfconDiametro]
, T.trfconTeleLectura
FROM [AVG].tarifasCalculadas AS T
INNER JOIN [AVG].TarvalCalculadas_2024 AS TV
ON T.[trfsrvcod] = TV.[trvsrvcod]
AND T.[trfcod] = TV.[trvtrfcod]
AND TV.trvcuota <> -1;


INSERT INTO tarval OUTPUT INSERTED.*
SELECT T.trvsrvcod
, [trvtrfcod] = T.trvtrfcod+1
, [trvfecha] = @fechaIniTrf
, [trvfechafin]=NULL
, [trvCuota] = TV.[trvCuota]
, T.[trvprecio1]
, T.[trvprecio2] 
, T.[trvprecio3] 
, T.[trvprecio4] 
, T.[trvprecio5] 
, T.[trvprecio6] 
, T.[trvprecio7] 
, T.[trvprecio8] 
, T.[trvprecio9] 
, [trvlegalavb] = 'BOP N. 137(17-07-2024)'
, T.trvlegal
, trvumdcod = UPPER(T.trvumdcod)
FROM [AVG].TarvalCalculadas AS T
INNER JOIN [AVG].TarvalCalculadas_2024 AS TV
ON T.[trvsrvcod] = TV.[trvsrvcod]
AND T.[trvtrfcod] = TV.[trvtrfcod]
AND TV.trvcuota <> -1;


--****************************************
--Asignamos fecha baja a las tarifas vigente
--SELECT *
UPDATE T SET T.trfFechaBaja=@fechaFinTrf, T.trfUsrBaja=@usuario, T.trfFecUltMod=@fechaReg, T.trfUsrUltMod=@usuario OUTPUT INSERTED.*
FROM dbo.tarifas AS T
INNER JOIN [AVG].TarvalCalculadas_2024 AS TV
ON T.trfsrvcod = TV.[trvsrvcod]
AND T.trfcod = TV.[trvtrfcod]
AND TV.trvcuota <> -1;

UPDATE TV SET TV.trvfechafin = @fechaFinTrf OUTPUT INSERTED.*
FROM tarval AS TV
INNER JOIN [AVG].TarvalCalculadas_2024 AS TT
ON TV.trvsrvcod = TT.trvsrvcod
AND TV.trvtrfcod = TT.trvtrfcod
AND TV.trvfechafin IS NULL
AND TV.trvfecha<@fechaFinTrf
AND TT.trvcuota <> -1;


SELECT * FROM tarifas WHERE trfFecUltMod=@fechaReg OR [trfFecReg] = @fechaReg;

SELECT * FROM tarval AS T 
INNER JOIN [AVG].TarvalCalculadas_2024 AS TT
ON T.trvsrvcod = TT.trvsrvcod
AND T.trvtrfcod IN ( TT.trvtrfcod,TT.trvtrfcod+1)  
AND TT.trvcuota <> -1
WHERE T.[trvfecha] = @fechaIniTrf OR T.trvfechafin = @fechaFinTrf

--COMMIT
ROLLBACK
