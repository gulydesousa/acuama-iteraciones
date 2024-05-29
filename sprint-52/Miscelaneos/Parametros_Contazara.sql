CREATE PROCEDURE dbo.Parametros_Contazara
AS

SELECT * 
FROM dbo.parametros
WHERE pgsclave LIKE 'CONTAZARA%'

GO


SELECT  F.facPerCod, F.facInspeccion, C.conNumSerie, CC.conTeleLectura
, CO.ctrComunitario
, CO.numHijosComunitarios
, DIAS = DATEDIFF(DAY, facLecAntFec, GETDATE())
, F.*
FROM facturas AS F
LEFT JOIN dbo.vCambiosContador AS C
ON C.ctrCod = F.facCtrCod 
AND C.esUltimaInstalacion=1
LEFT JOIN dbo.contador AS CC
ON CC.conID = C.conId
LEFT JOIN dbo.vContratosUltimaVersion AS CO
ON CO.ctrCod = F.facCtrCod

WHERE --F.facZonCod='7'AND 
F.facPerCod='202304' 
--AND F.facCtrCod= 23581
--AND F.facLote = 7
--AND CC.conNumSerie='P23NE855734A'
AND CC.conTeleLectura=1




SELECT  DISTINCT (CO.ctrzoncod)
FROM dbo.vContratosUltimaVersion AS CO
INNER JOIN  dbo.vCambiosContador AS C
ON C.ctrCod = CO.ctrcod 
AND C.esUltimaInstalacion=1
LEFT JOIN dbo.contador AS CC
ON CC.conID = C.conId
WHERE --F.facZonCod='7'AND 
--F.facPerCod='202304' 
--AND F.facCtrCod= 23581
--AND F.facLote = 7
--AND CC.conNumSerie='P23NE855734A'
--AND 
CC.conTeleLectura=1