BEGIN TRAN

DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240729';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf);


--****************************************
--Insertamos nuevas tarifas
INSERT INTO dbo.tarifas  OUTPUT INSERTED.*
SELECT TT.[trfsrvcod]
, [trfcod] = TT.trfcod+1
, [trfdes] = CONCAT(IIF(CHARINDEX(' - ', trfdes)=0, trfdes, LEFT(trfdes, CHARINDEX(' - ', trfdes) - 1)),' - BOP 137 (17-07-2024)')
, TT.trfescala1, TT.trfescala2, TT.trfescala3, TT.trfescala4, TT.trfescala5, TT.trfescala6, TT.trfescala7, TT.trfescala8, TT.trfescala9
, TT.trfpromedio
, [trfFechaBaja] = NULL
, trfUsrBaja = NULL
, TT.trfctacon
, TT.trfUdsPorEsc, TT.trfUdsPorPrecio, TT.trfBonificable
, trfFecUltMod = NULL
, trfUsrUltMod = NULL
, [trfFecReg] = @fechaReg
, [trfUsrReg] = @usuario
, TT.trfCodDesglose
, TT.trfCB
, TT.trfAplicarEscMax
, TT.trfAplicarEscMin
, [trfconDiametro] = ISNULL(TT.[trfconDiametro], T.Calibre)
, TT.trfconTeleLectura
FROM [AVG].tarifas AS T
INNER JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = T.ServicioCod
AND TT.trfcod = T.TarifaCod;


INSERT INTO tarval OUTPUT INSERTED.*
SELECT TV.trvsrvcod
, [trvtrfcod] = TV.trvtrfcod+1
, [trvfecha] = @fechaIniTrf
, [trvfechafin]=NULL
, [trvCuota] = IIF(T.trvCuota_2024 IS NULL, TV.[trvCuota],  ROUND(T.trvCuota_2024, 2))
, [trvprecio1] = IIF(T.trvprecio1 IS NULL, TV.trvprecio1,  ROUND(T.trvprecio1_2024, 4))
, [trvprecio2] = IIF(T.trvprecio2 IS NULL, TV.trvprecio2,  ROUND(T.trvprecio2_2024, 4))
, [trvprecio3] = IIF(T.trvprecio3 IS NULL, TV.trvprecio3,  ROUND(T.trvprecio3_2024, 4))
, TV.[trvprecio4] 
, TV.[trvprecio5] 
, TV.[trvprecio6] 
, TV.[trvprecio7] 
, TV.[trvprecio8] 
, TV.[trvprecio9] 
, [trvlegalavb] = 'BOP N. 137(17-07-2024)'
, TV.trvlegal
, trvumdcod = UPPER(TV.trvumdcod)
FROM [AVG].tarifas AS T
INNER JOIN tarval AS TV
ON TV.trvsrvcod = T.ServicioCod
AND TV.trvtrfcod = T.tarifaCod
AND TV.trvfechafin IS NULL;

--****************************************
--Asignamos fecha baja a las tarifas vigente
--SELECT *
UPDATE TT SET TT.trfFechaBaja=@fechaFinTrf, TT.trfUsrBaja=@usuario, TT.trfFecUltMod=@fechaReg, TT.trfUsrUltMod=@usuario OUTPUT INSERTED.*
FROM [AVG].tarifas AS T
INNER JOIN dbo.tarifas AS TT
ON TT.trfsrvcod = T.ServicioCod
AND TT.trfcod = T.TarifaCod;

--SELECT TV.*
UPDATE TV SET TV.trvfechafin = @fechaFinTrf OUTPUT INSERTED.*
FROM [AVG].tarifas AS T
INNER JOIN tarval AS TV
ON TV.trvsrvcod = T.ServicioCod
AND TV.trvtrfcod = T.tarifaCod
AND TV.trvfechafin IS NULL


SELECT * FROM tarifas WHERE trfFecUltMod=@fechaReg OR [trfFecReg] = @fechaReg;


SELECT * FROM tarval WHERE trvfechafin=@fechaFinTrf OR trvfecha=@fechaIniTrf ORDER BY trvsrvcod, trvtrfcod, trvfecha;


--COMMIT
ROLLBACK
