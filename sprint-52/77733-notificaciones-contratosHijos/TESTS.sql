--INSPECCION: 3610 - CTRCOD=3229 - OT: 3229
SELECT * FROM otInspecciones_Melilla WHERE otinum=27891

--HIJOS DE CTRCOD=3229
SELECT * FROM otInspeccionesContratos_Melilla WHERE INSPECCION=3610 AND [CONTRATO GENERAL]=3229

--_ENVIOS DEL CONTRATO PADRE:  CTRCOD=3229 - OT: 3229 (OT_INSPECCION)
--VACIO!!!
SELECT * FROM otInspeccionesNotificacionEdo_Melilla WHERE ot_inspeccion=3229 ORDER BY contrato

SELECT DISTINCT ot_inspeccion FROM otInspeccionesNotificacionEdo_Melilla


--EMISIONES
SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
WHERE objectid=3610


/*
27885
27886
27888
27890
27891
*/


SELECT otnum, otCtrCod FROM ordenTrabajo WHERE otnum IN(27885,27886,27888,27890,27891)

SELECT otnum, otCtrCod, I.objectid, I.ctrcod , C.[CONTRATO ABONADO], C.[CONTRATO GENERAL]
FROM ordenTrabajo AS O 
LEFT JOIN otInspecciones_Melilla AS I
ON I.otinum = O.otnum
AND I.otisercod = O.otsercod
AND I.otiserscd = O.otserscd
LEFT JOIN otInspeccionesContratos_Melilla AS C
ON C.INSPECCION = I.objectid
AND C.[CONTRATO GENERAL] = I.contrato
WHERE otnum IN(27885,27886,27888,27890,27891)
AND otnum=27891

SELECT * FROM otInspeccionesNotificacionEdo_Melilla WHERE ot_inspeccion=27891
ORDER BY contrato

--SELECT * FROM otInspeccionesNotificacionEdo_Melilla WHERE ot_inspeccion=27891 ORDER BY contrato

SELECT * FROM otInspeccionesNotificacionEdo_Melilla WHERE contrato=3229

--SELECT otdessolicitud, otCtrCod  FROM ordenTrabajo WHERE otnum=27890


--Fecha emision -30 DIAS
SELECT * 
--UPDATE E SET fecha= DATEADD(DAY, -30, fecha)
FROM [ReportingServices].[TO039_EmisionNotificaciones_Emisiones] AS E
WHERE usuario='mmorenol' AND emisionID=5

SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones

-- Fecha de entrega -26, fechaenvioboe -25, fechapubboe -24
SELECT *
--UPDATE M SET fecha1=DATEADD(DAY, -26, GETDATE()), fechaenvioboe= DATEADD(DAY, -25, GETDATE()), fechapubboe=DATEADD(DAY, -24, GETDATE())
FROM dbo.otInspeccionesNotificacionEdo_Melilla AS M 
WHERE ot_inspeccion=27891

--Consultar estados
SELECT * FROM vOtInspeccionesNotificacionEdo_Melilla



--CAMBIAMOS EL ESTADO AL PADRE

SELECT * 
--UPDATE C SET contrato=3229, codigo1=1--Entregado
FROM otInspeccionesNotificacionEdo_Melilla AS C WHERE ot_inspeccion=27891 AND contrato=26437

SELECT * FROM otInspeccionesNotificacionEstados

--[InformesExcel].[otInspecciones_EstadoEnvios]

SELECT * FROM vOtInspeccionesNotificacionEdo_Melilla

SELECT * FROM dbo.vOtInspeccionesAptas_Melilla
--
exec Contador_SelectInstalados @codigo=NULL,@contadorD=NULL,@contadorH=NULL,@contratoD=26415,@contratoH=26420,@fechaCompraD=NULL,@fechaCompraH=NULL,@fechaInstalacionD=NULL,@fechaInstalacionH=NULL,@incidenciaCambioContador=0,@inciLecInspD=NULL,@inciLecInspH=NULL,@inciLecLectorD=NULL,@inciLecLectorH=NULL,@ruta1=NULL,@ruta1H=NULL,@ruta2=NULL,@ruta2H=NULL,@ruta3=NULL,@ruta3H=NULL,@ruta4=NULL,@ruta4H=NULL,@ruta5=NULL,@ruta5H=NULL,@ruta6=NULL,@ruta6H=NULL,@SinOTAbiertas=1,@SoloConPlazoNotificacion=1,@SoloInspeccionesAptas=0,@zonaD=NULL,@zonaH=NULL