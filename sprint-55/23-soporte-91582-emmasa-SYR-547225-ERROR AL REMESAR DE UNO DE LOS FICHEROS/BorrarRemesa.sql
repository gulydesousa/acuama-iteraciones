SELECT efePdteCtrCod, efePdteUsrRemesada,  * 
--UPDATE E SET efePdteFecRemesada='2024-05-13T10:12:46.840', efePdteUsrRemesada ='spena'
FROM efectosPendientes AS E WHERE efePdteCtrCod = 67880 AND efePdteCod =7 AND efePdteFecRemesada IS NULL AND efePdteUsrRemesada IS NULL

--Borrar la marca de remesado en el efecto pendiente + BACKUP
SELECT * 
--UPDATE E SET efePdteFecRemesada=NULL, efePdteUsrRemesada =NULL
FROM efectosPendientes AS E WHERE efePdteCtrCod = 67880 AND efePdteCod =7 AND efePdteFecRemesada='2024-06-13T13:38:48.257' AND efePdteUsrRemesada ='spena'


--****************************
-- Si da exception mirar RemesasTrab
-- Lo ultimo que hace la tarea es borrar la tabla
-- Por ello es posible que hayar facturas ya cobradas y no te deje volver a remesar mientras no las limpies.
SELECT * 
FROM remesasTrab
WHERE remUsrCod='spena'


















--****************************************
--BACKUP DE LOS DATOS
--Descarga la tabla con datos de backup, y una vez copiada asegurate de borrarla
SELECT * 
--INTO SYR547225
FROM cobros  AS C
INNER JOIN coblin AS CL
ON CL.cblScd = C.cobScd
AND CL.cblPpag = C.cobPpag
AND CL.cblNum = C.cobNum
LEFT JOIN cobLinDes AS D
ON D.cldCblScd = C.cobScd
AND D.cldCblPpag = C.cobPpag
AND D.cldCblNum = C.cobNum
AND D.cldCblLin = CL.cblLin
LEFT JOIN cobLinEfectosPendientes AS E
ON E.cleCblScd = CL.cblScd
AND E.cleCblPpag = CL.cblPpag
AND E.cleCblNum = CL.cblNum
AND E.cleCblLin = CL.cblLin
LEFT JOIN dbo.efectosPendientes AS EP
ON EP.efePdteCod = E.clefePdteCod
AND EP.efePdteCtrCod = E.clefePdteCtrCod
AND EP.efePdtePerCod = E.clefePdtePerCod
AND EP.efePdteFacCod = E.clefePdteFacCod
AND EP.efePdteScd = E.clefePdteScd
WHERE cobOrigen = 'Remesa' AND cobConcepto LIKE '%Remesa: 1315. Fecha: 13/06/2024%'


--****************************************
--BORRAMOS la referencia a la remesa en las facturas
SELECT facNumeroRemesa, * 
--UPDATE F SET facFechaRemesa=NULL ,facNumeroRemesa=NULL
FROM facturas AS F WHERE facFechaRemesa>='20230613' AND facNumeroRemesa=1315

--****************************************
--ACTUALIZAMOS la referencia a la remesa en los efectos pendientes
-- [1] Efectos pendientes
SELECT EP.efePdteFecRemesada, EP.efePdteUsrRemesada, EP.efePdteCod, E0.clefePdteCod, EP.* 
--UPDATE EP SET efePdteFecRemesada=C0.cobFecReg, efePdteUsrRemesada =C0.cobUsr 

--UPDATE EP SET efePdteFecRemesada=NULL, efePdteUsrRemesada =NULL
FROM cobros  AS C
INNER JOIN coblin AS CL
ON CL.cblScd = C.cobScd
AND CL.cblPpag = C.cobPpag
AND CL.cblNum = C.cobNum
INNER JOIN cobLinEfectosPendientes AS E
ON E.cleCblScd = CL.cblScd
AND E.cleCblPpag = CL.cblPpag
AND E.cleCblNum = CL.cblNum
AND E.cleCblLin = CL.cblLin
INNER JOIN dbo.efectosPendientes AS EP
ON EP.efePdteCod = E.clefePdteCod
AND EP.efePdteCtrCod = E.clefePdteCtrCod
AND EP.efePdtePerCod = E.clefePdtePerCod
AND EP.efePdteFacCod = E.clefePdteFacCod
AND EP.efePdteScd = E.clefePdteScd
---******************************************
--Pendiente de pruebas
--Para volver a dejar la fecha del ultimo remesado
LEFT JOIN cobLinEfectosPendientes AS E0
ON E0.cleCblScd = E.cleCblScd
AND E0.cleCblPpag = E.cleCblPpag
AND E0.cleCblNum = E.cleCblNum
AND E0.cleCblLin = E.cleCblLin
AND E0.clefePdteCod = E.clefePdteCod-1
LEFT JOIN dbo.cobros AS C0
ON C0.cobPpag = E0.cleCblPpag
AND C0.cobScd = E0.cleCblScd
AND C0.cobNum = E0.cleCblNum
WHERE C.cobOrigen = 'Remesa' AND C.cobConcepto LIKE '%Remesa: 1317. Fecha: 13/06/2024%'



--****************************************
-- [2] Coblin Efectos Pendientes
SELECT E.* 
--DELETE E
FROM cobros  AS C
INNER JOIN coblin AS CL
ON CL.cblScd = C.cobScd
AND CL.cblPpag = C.cobPpag
AND CL.cblNum = C.cobNum
INNER JOIN cobLinEfectosPendientes AS E
ON E.cleCblScd = CL.cblScd
AND E.cleCblPpag = CL.cblPpag
AND E.cleCblNum = CL.cblNum
AND E.cleCblLin = CL.cblLin
WHERE cobOrigen = 'Remesa' AND cobConcepto LIKE '%Remesa: 1315. Fecha: 13/06/2024%'


--****************************************
--BORRAMOS los cobros: Desglose, Lineas, Cobros en ese orden!
SELECT * 
--DELETE C
--DELETE CL
--DELETE D
FROM cobros  AS C
LEFT JOIN coblin AS CL
ON CL.cblScd = C.cobScd
AND CL.cblPpag = C.cobPpag
AND CL.cblNum = C.cobNum
LEFT JOIN cobLinDes AS D
ON D.cldCblScd = C.cobScd
AND D.cldCblPpag = C.cobPpag
AND D.cldCblNum = C.cobNum
AND D.cldCblLin = CL.cblLin
WHERE cobOrigen = 'Remesa' AND cobConcepto LIKE '%Remesa: 1315. Fecha: 13/06/2024%'


