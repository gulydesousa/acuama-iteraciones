/*SELECT * FROM efectosPendientes WHERE efePdteCtrCod=110504373 and efePdteFacCod=1

SELECT * FROM facturas WHERE facCtrCod=110504373 AND facPerCod='000001'

SELECT * FROM cobLinEfectosPendientes WHERE clefePdteCtrCod=110504373 AND clefePdteFacCod=1


SELECT * FROM coblin WHERE cblNum=10890857

SELECT * FROM cobLinDes WHERE cldCblNum=10904709 and cldCblPpag=22

SELECT * FROM contratos WHERE ctrcod=110504373
*/
WITH C AS(
SELECT CL.*, EP.efePdteCod, EP.efePdteImporte
, CN= COUNT (cleCblNum) OVER (PARTITION BY CLEP.cleCblPpag, CLEP.cleCblScd, CLEP.cleCblNum, CLEP.cleCblLin)
, RN= ROW_NUMBER () OVER (PARTITION BY CLEP.cleCblPpag, CLEP.cleCblScd, CLEP.cleCblNum, CLEP.cleCblLin ORDER BY efePdteCod)
, S= SUM (EP.efePdteImporte) OVER (PARTITION BY CLEP.cleCblPpag, CLEP.cleCblScd, CLEP.cleCblNum, CLEP.cleCblLin )
, TotalAcumulado = SUM(EP.efePdteImporte) OVER (PARTITION BY CLEP.cleCblPpag, CLEP.cleCblScd, CLEP.cleCblNum, CLEP.cleCblLin ORDER BY EP.efePdteCod ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)

FROM coblin AS CL
INNER JOIN cobLinEfectosPendientes AS CLEP
ON CL.cblPpag = CLEP.cleCblPpag
AND CL.cblScd = CLEP.cleCblScd
AND CL.cblNum = CLEP.cleCblNum
AND CL.cblLin = CLEP.cleCblLin
INNER JOIN efectosPendientes AS EP
ON EP.efePdteCod = CLEP.clefePdteCod
AND EP.efePdteCtrCod = CLEP.clefePdteCtrCod
AND EP.efePdtePerCod = CLEP.clefePdtePerCod
AND EP.efePdteFacCod = CLEP.clefePdteFacCod
AND EP.efePdteScd = CLEP.cleCblScd

), Q AS(

SELECT *, 
Queda = cblImporte -(TotalAcumulado-efePdteImporte) 
FROM C
WHERE  S<> cblImporte)

SELECT * 
, CASE WHEN Queda<=0 THEN 0
	   WHEN RN<CN AND Queda> efePdteImporte THEN efePdteImporte
	   WHEN RN<CN AND Queda< efePdteImporte THEN Queda
	   ELSE Queda


END
FROM Q


