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
GROUP BY CS.ctsctrcod

--114 nuevas tarifas
), NUEVAS AS (
SELECT T.ServicioCod, T.TarifaCod FROM [AVG].tarifas AS T --66
UNION
SELECT trvsrvcod, trvtrfcod FROM [AVG].TarvalCalculadas_2024 WHERE trvcuota <>-1--48
) 

--21.037
SELECT CS.*
, maxLinea = ISNULL(maxLin, 0)
, iLinea = ROW_NUMBER() OVER (PARTITION BY CS.ctsctrcod ORDER BY ctslin)
INTO [AVG].ServiciosContrato
FROM contratoServicio AS CS
INNER JOIN NUEVAS AS T
ON CS.ctssrv = T.ServicioCod
AND CS.ctstar = T.TarifaCod
LEFT JOIN L
ON L.ctsctrcod = CS.ctsctrcod
WHERE (ctsfecbaj IS NULL OR ctsfecbaj>=@fechaIniTrf)
ORDER BY ctsfecbaj;

GO

SELECT * FROM [AVG].ServiciosContrato

