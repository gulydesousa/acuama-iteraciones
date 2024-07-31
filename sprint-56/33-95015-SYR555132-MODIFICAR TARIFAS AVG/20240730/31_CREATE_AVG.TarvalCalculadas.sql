DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240729';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf);
--2	CUOTA SERVICIO AGUA
--8	C. SANEAMIENTO Y DEPURACION

--SELECT * 
----INTO [AVG].TarvalCalculadas
--FROM dbo.tarifas AS T
--WHERE T.trfsrvcod IN (2, 8)
--AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaIniTrf)
--AND NOT(T.trfFecReg = @fechaReg AND T.trfUsrBaja= 'gmdesousa')
--ORDER BY T.trfsrvcod, T.trfcod;

--76
SELECT TV.* 
INTO [AVG].tarvalCalculadas
FROM [AVG].tarifasCalculadas AS T
INNER JOIN tarval AS TV
ON TV.trvsrvcod = T.trfsrvcod
AND TV.trvtrfcod = T.trfcod




--SELECT * FROM servicios
--SELECT * FROM [AVG].tarvalCalculadas