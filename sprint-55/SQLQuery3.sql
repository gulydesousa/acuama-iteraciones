/*
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

*/

--Enviadas a SERES
WITH F AS(

SELECT CN= COUNT(facNumero) OVER (PARTITION BY facNumero)
, RN= ROW_NUMBER() OVER (PARTITION BY facNumero ORDER BY facfecReg )
, * 
FROM facturas WHERE facPerCod='202402' AND facNumero IS NOT NULL
)

SELECT * FROM F WHERE facEnvSERES IS NOT NULL;

--Enviadas al SII
WITH F AS(

SELECT CN= COUNT(facNumero) OVER (PARTITION BY facNumero)
, RN= ROW_NUMBER() OVER (PARTITION BY facNumero ORDER BY facfecReg )
, facCod, facPerCod, facCtrCod, facVersion, facEnvSERES, facNumero, F.facObs
FROM facturas AS F WHERE facPerCod='202402' AND facNumero IS NOT NULL
)

SELECT RN= ROW_NUMBER() OVER(PARTITION BY fcSiiNumSerieFacturaEmisor ORDER BY fcSiiestado, facCtrcod),
DR= DENSE_RANK() OVER(ORDER BY fcSiiNumSerieFacturaEmisor),
S.fcSiiNumEnvio,
 S.fcSiiNumSerieFacturaEmisor, S.fcSiiestado, S.fcSiicodErr, S.fcSiidescErr, F.facEnvSERES,
*

FROM F
INNER JOIN facSII AS S
ON S.fcSiiFacCtrCod = F.facCtrCod
AND S.fcSiiFacPerCod = F.facPerCod
AND S.fcSiiFacCod = F.facCod
AND S.fcSiiFacVersion = F.facVersion
WHERE fcSiiNumEnvio=1 And fcSiicodErr IS NULL
