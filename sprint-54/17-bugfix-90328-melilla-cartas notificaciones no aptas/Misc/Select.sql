--Cartas emitidas
SELECT objectid, Servicio, CONTRATOCOMUNITARIO, REPRESENTANTE, emisionID
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE REPRESENTANTE IS NOT NULL 
AND otApta='SI' 
AND Servicio= 'BATERIAS'
AND CONTRATOCOMUNITARIO IS NOT NULL

--Cartas emitidas
SELECT objectid, Servicio, CONTRATOCOMUNITARIO, REPRESENTANTE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE REPRESENTANTE IS NOT NULL 
AND otApta='SI' 
AND Servicio= 'BATERIAS'
AND CONTRATOCOMUNITARIO IS NOT NULL 

SELECT * FROM otInspeccionesValidaciones where otivServicioCod=1 and otivCritica=0


--Cartas por Emision
SELECT N.emisionID, N.otApta, N.Servicio, NUmCartas= COUNT(objectid) 
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
GROUP BY N.emisionID, N.otApta, N.Servicio
ORDER BY N.emisionID, N.otApta, N.Servicio


--Cartas emitidas
SELECT objectId, Servicio, CONTRATO, otApta 
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE emisionID=5
ORDER BY CONTRATO

SELECT objectId, Servicio, CONTRATO, otApta 
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE objectid= 3510
ORDER BY CONTRATO


SELECT *
--DELETE
FROM otInspeccionesNotificacionEmisiones_Melilla
WHERE  otineEmision=28

SELECT * FROM otInspecciones_Melilla WHERE  objectid= 3264

SELECT objectId, Servicio, CONTRATO, otApta 
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE emisionID=28 AND objectid= 3264
ORDER BY CONTRATO



--(24 rows affected)
SELECT FISTEL, FISTEL2, MAILDATOS, otNum , SERVICIO, CONTRATOCOMUNITARIO
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE emisionID=22 ORDER BY FISTEL, FISTEL2, MAILDATOS

SELECT FISTEL, FISTEL2, MAILDATOS, otNum, emisionID
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE (FISTEL IS NULL OR FISTEL='') 

SELECT FISTEL, FISTEL2, MAILDATOS, otNum, emisionID, TITULARCPOSTAL
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE emisionID=20
SELECT DEVELOP = IIF(DB_NAME()='ACUAMA_MELILLA_DESA', 1, 0) 



SELECT *
--DELETE FROM E
FROM otInspeccionesNotificacionEmisiones_Melilla AS E
INNER JOIN  ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
ON N.objectid = E.otineObjectID
WHERE ISNUMERIC(TITULARCPOSTAL)=0 AND otApta<>'APTO 100%' 



SELECT *
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE ISNUMERIC(TITULARCPOSTAL)=0 AND otApta<>'APTO 100%'



SELECT *
--DELETE FROM E
FROM otInspeccionesNotificacionEmisiones_Melilla AS E
LEFT JOIN  ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
ON N.objectid = E.otineObjectID
WHERE N.objectid IS NULL



SELECT FISNOM, LEN(FISNOM), emisionID
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE LEN(FISNOM)>30 AND emisionID<>24 AND otApta<>'APTO 100%'

SELECT FISDIR1 , LEN(FISDIR1) FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones ORDER BY LEN(FISDIR1)




SELECT *
--DELETE FROM E
FROM otInspeccionesNotificacionEmisiones_Melilla AS E
--INNER JOIN  ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
--ON N.objectid = E.otineObjectID
WHERE  otineEmision=42



SELECT FISNOM, LEN(FISNOM), emisionID, otApta
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE  emisionID=42

emisionID=29 AND otApta<>'APTO 100%' AND CONTRATOCOMUNITARIO IS NOT NULL


--Revertir la emision de los contratos padres comunitarios
DECLARE @T AS TABLE (CONTRATOCOMUNITARIO INT);
INSERT INTO @T
SELECT DISTINCT CONTRATOCOMUNITARIO
FROM  ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE  emisionID=26;


SELECT *
--DELETE FROM E
FROM otInspeccionesNotificacionEmisiones_Melilla AS E
INNER JOIN  ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
ON N.objectid = E.otineObjectID
INNER JOIN @T AS CC
ON N.CONTRATO=CC.CONTRATOCOMUNITARIO AND otApta<>'APTO 100%'

SELECT FISNOM, LEN(FISNOM), emisionID
--DELETE N
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
INNER JOIN @T AS CC
ON N.CONTRATO=CC.CONTRATOCOMUNITARIO AND otApta<>'APTO 100%'



--Inspecciones Masivas:
SELECT *
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE objectid=5079 AND CONTRATO=18706


SELECT *
--DELETE
FROM otInspeccionesNotificacionEmisiones_Melilla
WHERE otineObjectID=5079  AND otineCtrCod=18706


SELECT * FROM votInspecciones_Melilla WHERE objectid=3339


SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser='gmdesousa' AND tskErrorMsg IS NOT NULL

SELECT *
--DELETE FROM E
FROM otInspeccionesNotificacionEmisiones_Melilla AS E
INNER JOIN  ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
ON N.objectid = E.otineObjectID
WHERE  emisionID>40 AND otApta<>'APTO 100%' AND CONTRATOCOMUNITARIO IS NOT NULL



SELECT FISNOM, LEN(FISNOM), emisionID
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE  emisionID<40 AND otApta<>'APTO 100%' AND CONTRATOCOMUNITARIO IS NOT NULL


--Revertir la emision de los contratos padres comunitarios
DECLARE @T AS TABLE (CONTRATOCOMUNITARIO INT);
INSERT INTO @T
SELECT DISTINCT CONTRATOCOMUNITARIO
FROM  ReportingServices.TO039_EmisionNotificaciones_Notificaciones
--WHERE  emisionID<40;


SELECT *
--DELETE FROM E
FROM otInspeccionesNotificacionEmisiones_Melilla AS E
INNER JOIN  ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
ON N.objectid = E.otineObjectID
INNER JOIN @T AS CC
ON N.CONTRATO=CC.CONTRATOCOMUNITARIO AND otApta<>'APTO 100%'

SELECT FISNOM, LEN(FISNOM), emisionID
--DELETE N
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
INNER JOIN @T AS CC
ON N.CONTRATO=CC.CONTRATOCOMUNITARIO AND otApta<>'APTO 100%'