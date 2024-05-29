SELECT * FROM otInspeccionesNotificacionEmisiones_Melilla
SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones

--Fecha emision -30 DIAS
SELECT * 
--UPDATE E SET fecha= DATEADD(DAY, -30, fecha)
FROM [ReportingServices].[TO039_EmisionNotificaciones_Emisiones] AS E
WHERE usuario='mmorenol' AND emisionID=95

-- Fecha de entrega -26, fechaenvioboe -25, fechapubboe -24
SELECT *
--UPDATE M SET fecha1=DATEADD(DAY, -26, GETDATE()), fechaenvioboe= DATEADD(DAY, -25, GETDATE()), fechapubboe=DATEADD(DAY, -24, GETDATE())
FROM dbo.otInspeccionesNotificacionEdo_Melilla AS M 
WHERE contrato=5339

SELECT DATEADD(DAY, -26, GETDATE())

SELECT * FROM vOtInspeccionesNotificacionEdo_Melilla 