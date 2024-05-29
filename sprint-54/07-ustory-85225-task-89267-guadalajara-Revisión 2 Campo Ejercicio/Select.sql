--Facturas que presentan cambios
--202201: Se comprueba que las unicas diferencias están en las facturas rectificadas
--Comportamiento original en las facturas de consumo: AÑO_LIQ: Año de la fecha  factura
--Comportamiento actual: YEAR(F_EMISION)
-- ¿PreguNTAR A mARTA?
DECLARE @ID AS INT= 27;
SELECT F.facNumero, F.facCtrCod, F.facPerCod, P.perFecIniPagoVol
, F.facFecha, [F0] = F0.facFecha
, [Y0] = YEAR(F0.facFecha), [Y]= YEAR(F.facFecha)
FROM apremios AS A 
INNER JOIN facturas AS F
ON F.facCtrCod = A.aprFacCtrCod
AND F.facPerCod = A.aprFacPerCod
AND F.facVersion = A.aprFacVersion
AND F.facCod = A.aprFacCod
AND  aprNumero=@ID
LEFT JOIN facturas AS F0
ON F0.facCtrCod = A.aprFacCtrCod
AND F0.facPerCod = A.aprFacPerCod
AND F0.facVersion = A.aprFacVersion - 1
AND F0.facCod = A.aprFacCod
LEFT JOIN periodos AS P
ON P.percod = F.facPerCod
WHERE F0.facCtrCod IS NOT NULL 
OR YEAR(F.facFecha)<> YEAR(P.perFecIniPagoVol)
ORDER BY F.facNumero



RETURN







--Rectificadas en un año diferente al de la factura inicial
SELECT A.*, F0= F.facFecha, FR=FF.facFecha, PP.perFecFinPagoVol
FROM apremios AS A
LEFT JOIN facturas AS FF 
ON FF.facCtrCod = A.aprFacCtrCod
AND A.aprFacPerCod = FF.facPerCod
AND A.aprFacCod = FF.facCod
AND FF.facCtrVersion= A.aprFacVersion
LEFT JOIN facturas AS F 
ON F.facCtrCod = A.aprFacCtrCod
AND A.aprFacPerCod = F.facPerCod
AND A.aprFacCod = F.facCod
AND F.facCtrVersion=1
LEFT JOIN perzona AS P
ON P.przcodper = F.facPerCod
AND P.przcodzon = F.facZonCod
LEFT JOIN periodos AS PP
ON PP.percod = F.facPerCod
WHERE aprFacVersion>1
AND YEAR(F.facFecha)<>YEAR(FF.facFecha)
ORDER BY aprFacPerCod



SELECT F0= F.facFecha, FR=FF.facFecha, PP.perFecFinPagoVol
FROM facturas AS FF 
LEFT JOIN facturas AS F 
ON F.facCtrCod = FF.facCtrCod
AND FF.facPerCod = F.facPerCod
AND FF.facCod = F.facCod
AND F.facCtrVersion=1
LEFT JOIN perzona AS P
ON P.przcodper = F.facPerCod
AND P.przcodzon = F.facZonCod
LEFT JOIN periodos AS PP
ON PP.percod = F.facPerCod
WHERE FF.facVersion>1 AND FF.facFechaRectif IS NULL
--AND YEAR(F.facFecha)<>YEAR(FF.facFecha)
AND FF.facCtrCod IN (2528,4592,6445) AND FF.facPerCod='202201'


SELECT FF.facCtrCod, FF.facPerCod,  FF.facNumero, FF.facCtrCod, FR= FF.facFecha, F1=F.facFecha, PP.perFecFinPagoVol, T.fctDeuda
FROM facturas AS FF 
LEFT JOIN  facturas AS F
ON FF.facCtrCod = F.facCtrCod
AND FF.facPerCod = F.facPerCod
AND FF.facCtrCod = F.facCtrCod
AND F.facVersion = 1
LEFT JOIN periodos AS PP
ON PP.percod = F.facPerCod
INNER JOIN dbo.apremios AS A
ON A.aprFacCtrCod = FF.facCtrCod
AND A.aprFacPerCod = FF.facPerCod
AND A.aprFacCod = FF.facCod
AND A.aprFacVersion = FF.facVersion
AND A.aprFechaGeneracion>='20240523'
--AND A.aprCobrado= 0 AND A.aprCobradoAcuama= 0
LEFT JOIN dbo.facTotales AS T
ON FF.facCod = T.fctCod
AND FF.facPerCod = T.fctPerCod
AND FF.facCtrCod = T.fctCtrCod
AND FF.facVersion = T.fctVersion
WHERE FF.facVersion>1 
AND FF.facFechaRectif IS NULL 
AND YEAR(F.facFecha)<>YEAR(FF.facFecha)
AND FF.facCtrCod IN (2528,4592,6445) AND FF.facPerCod='202201'
AND T.fctDeuda > 0 
ORDER BY facPerCod

SELECT * 
--DELETE
FROM apremios WHERE aprFechaGeneracion>='20240523'


SELECT *
--DELETE A
FROM  dbo.apremios AS A
INNER JOIN dbo.facTotales AS T
ON A.aprfacCod = T.fctCod
AND A.aprfacPerCod = T.fctPerCod
AND A.aprfacCtrCod = T.fctCtrCod
AND A.aprfacVersion = T.fctVersion
AND T.fctDeuda > 0 
AND aprFacPerCod LIKE '00%'


AND aprFechaGeneracion>'20200101'


SELECT * FROM apremios WHERE aprFechaGeneracion>'20240523' and aprFacPerCod LIKE '00%'

SELECT * FROM Task_Schedule WHERE tskUser='gmdesousa'

declare @p6 int
set @p6=0
exec ApremiosTrab_Insert @apremioAyto='TodosAyto',@aptTipo=1,@aptUsrCod='gmdesousa',@periodoD='202201',@periodoH='202201',@regAfectados=@p6 output
select @p6

TRUNCATE TABLE apremiosTrab