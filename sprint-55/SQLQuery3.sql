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
/*
--Enviadas a SERES
WITH F AS(

SELECT CN= COUNT(facNumero) OVER (PARTITION BY facNumero)
, RN= ROW_NUMBER() OVER (PARTITION BY facNumero ORDER BY facfecReg )
, * 
FROM facturas WHERE facPerCod='202402' AND facNumero IS NOT NULL
)

SELECT * FROM F WHERE facEnvSERES IS NOT NULL;
*/

/*
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
*/


--[00]Esquema para dejar las tablas con los datos seleccionados
--CREATE SCHEMA BUG91542; 
--DROP TABLE BUG91542.facEmitidas


--*********************************************************
--*********************************************************
--[01]Facturas 202402
--5.356 Facturas en total
--Extraemos el numero de factura original (antes del update)
DECLARE @cadenaBuscar VARCHAR(MAX) = 'SYR-549588 -facnu repe ';
DECLARE @posicion INT;

SELECT facCod, facPerCod, facCtrCod, facVersion, facEnvSERES,  facfecReg
, facNumero --Numeros despues del update
--Todos los numeros de factura antes del update
, NumeroEmision = facNumero 
--Numero antes del update
, NumeroKO = TRIM(SUBSTRING(F.facObs,  CHARINDEX(@cadenaBuscar, F.facObs) + LEN(@cadenaBuscar), LEN(F.facObs) -  CHARINDEX(@cadenaBuscar, F.facObs) + LEN(@cadenaBuscar) + 1))
, facObs
INTO BUG91542.facEmitidas
FROM facturas AS F 
WHERE facPerCod='202402' AND facNumero IS NOT NULL;

SELECT * FROM BUG91542.facEmitidas;


--*********************************************************
--[02]Actualizamos en NumeroEmision el numero original antes del update de emergencia
--3.085
SELECT *
--UPDATE F SET NumeroEmision = NumeroKO
FROM BUG91542.facEmitidas AS F WHERE LEN(NumeroKO) > 0

--SELECT * FROM BUG91542.facEmitidas


--[03]Contamos las emisiones por NumeroEmision (factura original)

SELECT F.*
-- Id Grupo
, DR = DENSE_RANK() OVER (ORDER BY NumeroEmision)
--Ocurrencias por numero de factura
, CN= COUNT(NumeroEmision) OVER (PARTITION BY NumeroEmision)
--Instancia por numero de factura
, RN= ROW_NUMBER() OVER (PARTITION BY NumeroEmision ORDER BY facfecReg ) 
FROM BUG91542.facEmitidas AS F;


--[04]Contamos los envios al SII de estas facturas
--DROP TABLE BUG91542.facEnviadas
SELECT F.*, S.fcSiiNumSerieFacturaEmisor, S.fcSiiFechaExpedicionFacturaEmisor, S.fcSiiestado, S.fcSiicodErr, S.fcSiidescErr, S.fcSiiNumEnvio, S.fcSiiLoteID, L.fcSiiLtFecEnvSap, L.fcSiiLtEnvEstado, L.fcSiiLtEnvErrorDescripcion
--Numero de envios al SII por factura
, ENVxF = COUNT(S.fcSiiNumEnvio) OVER (PARTITION BY faccod, facPerCod, facCtrCod, facVersion)
--Numero de envios al SII por numero de factura: Enumera cada numero de factura SII
, DRxN = DENSE_RANK() OVER(ORDER BY S.fcSiiNumSerieFacturaEmisor)
--Total de facturas acuama associadas a una misma factura SII
, ENVxN = COUNT(S.fcSiiNumSerieFacturaEmisor) OVER (PARTITION BY fcSiiNumSerieFacturaEmisor)
--Orden dentro de un mismo grupo de factura SII
, RNxN = ROW_NUMBER() OVER (PARTITION BY fcSiiNumSerieFacturaEmisor ORDER BY L.fcSiiLtFecEnvSap DESC)

--Orden para quedarnos con el ultimo envio
--Orden: Si ha sido aceptado, no ha sido aceptado pero esta pendiente de envio, si no está en los dos casos previos: trae el ultimo envio.
, RN_SII = ROW_NUMBER() OVER (PARTITION BY faccod, facPerCod, facCtrCod, facVersion ORDER BY CASE WHEN fcSiiestado IS NOT NULL AND  fcSiiestado=1 THEN 0 WHEN fcSiiestado IS  NULL THEN 1 ELSE 99 END, fcSiiNumEnvio DESC)

INTO BUG91542.facEnviadas
FROM BUG91542.facEmitidas AS F
LEFT JOIN dbo.facSII AS S
ON S.fcSiiFacCod = F.facCod
AND S.fcSiiFacPerCod = F.facpercod
AND S.fcSiiFacCtrCod = F.facCtrcod
AND S.fcSiiFacVersion = F.facversion
LEFT JOIN facSIILote AS L
ON L.fcSiiLtID = S.fcSiiLoteID
ORDER BY fcSiiFacCtrCod




SELECT * 

FROM BUG91542.facEnviadas WHERE RN_SII=1 OR RN_SII IS NULL
ORDER BY DRxN, RNxN

