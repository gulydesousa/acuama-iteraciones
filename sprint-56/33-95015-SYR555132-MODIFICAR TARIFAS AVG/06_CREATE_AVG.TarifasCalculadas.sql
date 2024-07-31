--Tarifas potencialmente actualizables con el calculo de margari

DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240729';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf);

SELECT * 
INTO [AVG].TarifasCalculadas
FROM dbo.tarifas AS T
WHERE T.trfsrvcod IN (2, 8)
AND (trfFechaBaja IS NULL OR trfFechaBaja>@fechaIniTrf)
AND NOT(T.trfFecReg = @fechaReg AND T.trfUsrBaja= @usuario)
ORDER BY T.trfsrvcod, T.trfcod;
GO

SELECT * FROM [AVG].TarifasCalculadas;