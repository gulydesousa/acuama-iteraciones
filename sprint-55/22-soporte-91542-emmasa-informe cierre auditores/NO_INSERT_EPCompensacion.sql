--INSERT INTO cobLinEfectosPendientes VALUES(1, 92, 10893404, 1, 6, 109001883, '202004', 1, 1)
--INSERT INTO cobLinEfectosPendientes VALUES(1, 92, 10893405, 1, 3, 106500904, '202005', 1, 1)
--INSERT INTO cobLinEfectosPendientes VALUES(1, 92, 10893403, 1, 10861739, 110236365, '202003', 1, 1)


SELECT * 
--UPDATE E SET ExcConsulta='Excel_ExcelConsultas.DeudaAuditoresSevilla_EMMASA'
--UPDATE E SET ExcConsulta='[InformesExcel].[DeudaAuditoresSevilla_EMMASA]'
FROM ExcelConsultas AS E
WHERE E.ExcCod='321'	


SELECT * 
--DELETE
FROM cobLinEfectosPendientes WHERE cleCblNum IN (10893404, 10893403, 10893405) AND cleCblPpag=92