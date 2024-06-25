SELECT 
COUNT(facCtrcod) OVER (PARTITION BY facnumero),
* FROm facturas AS F 
WHERE facpercod='202402'
--3.085


WITH A AS(
SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumero
, RN=ROW_NUMBER() OVER (ORDER BY facFecReg ASC)

FROM facSII AS S
INNER JOIN facturas AS F
ON F.facCod= S.fcSiiFacCod
AND F.facPerCod = S.fcSiiFacPerCod
AND F.facCtrCod = S.fcSiiFacCtrCod
AND F.facVersion = S.fcSiiFacVersion
WHERE fcSiiFacPerCod='202402'
AND fcSiidescErr='Factura duplicada'and fcSiiFacCtrCod<>14)

SELECT A.*, F.facNumero, Nuevo = 5242+A.RN, facObs='SYR'+F.facNumero
--UPDATE F SET F.facNumero = 5242, , facObs='SYR'+F.facNumero
FROM dbo.facturas AS F
INNER JOIN A 
ON A.facCtrCod = F.facCtrCod
AND A.facPerCod = F.facPerCod
AND A.facCod = F.facCod
AND A.facVersion = F.facVersion


select  * from facsii 
where fcSiiFacPerCod = '202402' 
and fcSiidescErr='Factura duplicada'and fcSiiFacCtrCod<>14
order by fcSiiFechaExpedicionFacturaEmisor desc