--****************************
SELECT V.Apta, * 
FROM otInspecciones_Melilla AS T
LEFT JOIN vOtInspecciones_Melilla AS V
ON T.objectid = V.objectid
WHERE V.Apta='NO'
AND T.zona < 'ZONA 4'
AND T.ruta2 < 40
ORDER BY T.zona
--1997 filas *****************


------------------------------
SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones 
WHERE emisionEstado='Emitir'
--3894 filas
--****************************


SELECT V.Apta, T.objectid, T.ctrcod, V.ctrcod, V.CTRCOD_INSPECCION
, R.objectid 
FROM otInspecciones_Melilla AS T
LEFT JOIN vOtInspecciones_Melilla AS V
ON T.objectid = V.objectid
LEFT JOIN ReportingServices.TO039_EmisionNotificaciones_Notificaciones  AS R
ON R.emisionEstado='Emitir'
AND R.CONTRATO= V.ctrcod
AND R.objectid = V.objectid
WHERE V.Apta='NO'
AND T.zona > 'ZONA 4'
AND R.objectid is NULL
ORDER BY T.zona


--*****************************
SELECT * FROM votInspecciones_Melilla WHERE objectid = 6047
SELECT * FROM vOtInspeccionesNotificacionEmisiones_Melilla WHERE ctrcod BETWEEN 18685 AND 18712

--*****************************

--DELETE FROM otInspeccionesNotificacionEdo_Melilla




SELECT V.Apta, * 
FROM otInspecciones_Melilla AS T
LEFT JOIN vOtInspecciones_Melilla AS V
ON T.objectid = V.objectid
WHERE V.Apta<>'NO'
ORDER BY T.ctrcod



SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones 
WHERE emisionEstado='Emitir'


SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones WHERE objectid=3100

--3100




SELECT V.Apta, V.ctrcod, R.objectid, V.objectid
FROM otInspecciones_Melilla AS T
LEFT JOIN vOtInspecciones_Melilla AS V
ON T.objectid = V.objectid
LEFT JOIN ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS R
ON R.objectid = V.objectid	
AND R.CONTRATO = V.ctrcod
AND emisionEstado='Emitir'
WHERE V.Apta='NO'
AND T.zona IN ('ZONA 1', 'ZONA 4','ZONA 2', 'ZONA 3')
--AND  R.objectid IS NULL
ORDER BY T.zona

SELECT * FROM otInspeccionesContratos_Melilla WHERE INSPECCION=3127

/*
DELETE  FROM otInspeccionesNotificacionEmisiones_Melilla
TRUNCATE TABLE ReportingServices.TO039_EmisionNotificaciones_Notificaciones
DELETE  FROM  [ReportingServices].[TO039_EmisionNotificaciones_Emisiones]
*/

SELECT * 
FROM otInspeccionesNotificacionEmisiones_Melilla AS N
INNER JOIN vOtInspecciones_Melilla AS V
ON N.otineObjectID = V.objectid
AND V.Apta<>'NO'

SELECT * FROM votInspecciones_Melilla WHERE objectid=3100 ORDER BY ctrcod
SELECT * FROM otInspecciones_Melilla WHERE objectid=3127
SELECT * FROM vOtInspeccionesNotificacionEmisiones_Melilla WHERE objectid=3168

--OT: 39584
--Inspeccion: 3339
--Contrato: 18685
--Contratos Hijos.18685- 18712
--Emision de notificaciones por contrato: 18685- 18712


SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser='gmdesousa'

SELECT * FROM vContratosUltimaVersion

SELECT T.objectid, CC.ctrRepresent, C.ctrcod, * 
FROM vOtInspecciones_Melilla AS T
LEFT JOIN dbo.vContratosUltimaVersion AS C
ON C.ctrcod = T.ctrcod
INNER JOIN dbo.contratos AS CC
oN CC.ctrcod = C.ctrCod
AND CC.ctrversion = C.ctrVersion
WHERE NUM_ABONADOS>1 
AND T.objectid=3127
--AND CTRCOD_INSPECCION= T.ctrcod
--AND ctrRepresent IS NOT NULL
--AND 


/*
Si el contrato tiene representante, se emite una carta para el titular y una para el representante del contrato padre
Se emite una carta para cada uno de los hijos.
La dirección que figura en las cartas es la del inmueble.

-- SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
-- SELECT * FROM otInspecciones_Melilla WHERE objectid=3168
-- SELECT * FROM votInspecciones_Melilla WHERE objectid=3168

--*********************
--CASO 1
Inspeccion objectid: 3168
Contrato Padre: 2123
5 HIJOS: 16248, 16249, 16250, 16251, 16252
- Carta Contrato Inspección (A pesar que no estaba entre los contratos hijos)
- Una carta para cada hijo
- Si el hijo tiene representante, también tiene su carta el representante hijo

--*********************
--CASO 2
Inspeccion objectid: 3127
Contrato padre: 1703, con representante: MONCADA DEL CAMPO MARIA INES
Tienen 6 abonados, entre los que no está el padre: 28873-28878
- Carta para el padre
- Carta para el representante del padre
- Carta para cada hijo
- El hijo con representante recibe carta




*/

