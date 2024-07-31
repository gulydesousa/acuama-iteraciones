/*
--Buscar las facturas 
--SELECT * FROM BUG91542.EnviosSII

--6.788
SELECT * 
FROM facturas WHERE facPerCod='202402' AND facEnvSap=1

--Para cada factura veamos cuales de version 1 están en el SII
--5.378
SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumero, f.facObs, S.* 
FROM facturas AS F 
LEFT JOIN dbo.facSII AS S
ON F.facCod = S.fcSiiFacCod
AND F.facPerCod = S.fcSiiFacPerCod
AND F.facCtrCod = S.fcSiiFacCtrCod
AND F.facVersion = S.fcSiiFacVersion
WHERE facPerCod='202402'  AND facVersion=1 AND facEnvSap=1;

SELECT * FROM facturas WHERE facPerCod='202402' AND facCtrCod=38;

SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumero, f.facObs, S.* 
FROM facturas AS F 
LEFT JOIN dbo.facSII AS S
ON F.facCod = S.fcSiiFacCod
AND F.facPerCod = S.fcSiiFacPerCod
AND F.facCtrCod = S.fcSiiFacCtrCod
AND F.facVersion = S.fcSiiFacVersion
WHERE facPerCod='202402'  AND facCtrCod=38;

--Contrato#8, facNumero=2410006221; SYR-549588 -facnu repe 2410005264
--fcSiiNumSerieFacturaEmisor: A-2024/2410005264
--Factura duplicada

SELECT * FROM NumerosOcupados
--Son las que hay que reenviar
--
Ocupado=0 ---Estas son las que


----
--Num duplicado y genero la rectuficatva
--Comprobar que han entrado las rectificativas
FcsiiFActurasParaAnularRectificar

*/
--5.659
--SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion 
--FROM BUG91542.NumerosOcupados 
--INNER JOIN facturas AS F
--ON F.facPerCod='202402' AND facNumero=NumFactura AND Ocupado=0


WITH S AS(
SELECT fcSiiFacCod,fcSiiFacPerCod, fcSiiFacCtrCod, fcSiiFacVersion, S.fcSiiNumSerieFacturaEmisor, S.fcSiicodErr, S.fcSiidescErr, S.fcSiiNumEnvio, S.fcSiiestado, fcSiiLoteID
, RN = ROW_NUMBER() OVER (PARTITION BY fcSiiFacCod,fcSiiFacPerCod, fcSiiFacCtrCod, fcSiiFacVersion ORDER BY  IIF(S.fcSiiestado IS NOT NULL AND S.fcSiiestado=1, 1, S.fcSiiestado), S.fcSiiNumEnvio DESC)
FROM facSII AS S
WHERE fcSiiFacPerCod='202402')

--6788
SELECT facCod, facPerCod, facCtrCod, facVersion, facNumero, facNumeroAqua
, RN = ROW_NUMBER() OVER(PARTITION BY facCod, facPerCod, facCtrCod ORDER BY facVersion DESC)
, CN = COUNT(facVersion) OVER(PARTITION BY facCod, facPerCod, facCtrCod)
, S.fcSiiNumSerieFacturaEmisor
, S.fcSiicodErr
, S.fcSiidescErr
, S.fcSiiNumEnvio
, S.fcSiiestado
, fcSiiLoteID
FROM facturas AS F
LEFT JOIN S
ON S.fcSiiFacCtrCod = F.facCtrCod
AND S.fcSiiFacPerCod = F.facPerCod
AND S.fcSiiFacVersion = F.facVersion
AND S.fcSiiFacCod = F.facCod
AND S.RN=1
WHERE facPerCod='202402'

--SELECT * FROM facturas WHERE facPerCod='202402' AND facCtrCod='51341'