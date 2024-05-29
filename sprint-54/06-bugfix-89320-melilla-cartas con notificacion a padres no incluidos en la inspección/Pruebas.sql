--SELECT * FROM otInspecciones_Melilla
--SELECT * FROM otInspeccionesContratos_Melilla
--SELECT * FROM votInspecciones_Melilla
----Resultado esperado:30 inspecciones una por cada contrato hijo del contrato general 28849
----Cargamos inspecciones sin contratos hijos
----Resultado esperado: 1 inspección por cada contrato general (aunque no tenga hijos)
----Una carta por cada inspeccion 19
----Una carta para cada hijo, siempre y cuando forme parte de la inspección 53

----Borrar las notificaciones
--SELECT * 
----DELETE 
--FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones 
--WHERE objectid IN (3254,3255)


--SELECT * 
----DELETE
--FROM otInspeccionesNotificacionEmisiones_Melilla
--WHERE otineObjectID IN (3254,3255)


--SELECT * 
----DELETE
--FROM otInspeccionesContratos_Melilla WHERE INSPECCION IN (3254,3255)

--C:\Gdesousa\_Sacyr\sql-sprints\sprint-54\06-bugfix-89320-melilla-cartas con notificacion a padres no incluidos en la inspección

--72
SELECT * FROM otInspecciones_Melilla --19
SELECT * FROM otInspeccionesContratos_Melilla --53
SELECT * FROM votInspecciones_Melilla --19

--Aptas: 5
--No.Aptas: 68
--73

SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones

SELECT * FROM votInspecciones_Melilla WHERE MOCK=0


SELECT M.objectid, M.ctrcod, C.[CONTRATO ABONADO], C.[CONTRATO GENERAL]
, [Como Abonado] = IIF(C.[CONTRATO ABONADO]=M.ctrcod,'X' ,NULL)
FROM otInspecciones_Melilla AS M
LEFT JOIN otInspeccionesContratos_Melilla AS C
ON M.objectid = C.INSPECCION

SELECT * FROM vOtInspeccionesNotificacionEmisiones_Melilla

SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones WHERE emisionEstado='Emitir' ORDER BY objectid