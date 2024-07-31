--Buscamos en servicios por contrato con alguno de estos servicios activos
--DROP TABLE [AVG].ServiciosContrato
DECLARE @usuario VARCHAR(10) = 'gmdesousa';
DECLARE @fechaReg DATE = '20240729';
--La fecha inicio de la nueva tarifa
DECLARE @fechaFinTrf DATE = '20240801';
DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf);

WITH L AS(
SELECT CS.ctsctrcod
, maxLin= MAX(ctslin)
FROM contratoServicio AS CS
GROUP BY CS.ctsctrcod)


SELECT CS.*
, maxLinea = ISNULL(maxLin, 0)
, iLinea = ROW_NUMBER() OVER (PARTITION BY CS.ctsctrcod ORDER BY ctslin)
INTO [AVG].ServiciosContrato
FROM contratoServicio AS CS
INNER JOIN [AVG].tarifas AS T
ON CS.ctssrv = T.ServicioCod
AND CS.ctstar = T.Tarifa
LEFT JOIN L
ON L.ctsctrcod = CS.ctsctrcod
WHERE (ctsfecbaj IS NULL OR ctsfecbaj>=@fechaIniTrf)
ORDER BY ctsfecbaj;

