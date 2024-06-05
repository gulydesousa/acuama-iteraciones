SELECT * 
--DELETE
FROM otInspeccionesContratos_Melilla

SELECT *
--DELETE
FROM otInspeccionesNotificacionEdo_Melilla

SELECT * 
--DELETE
FROM otInspeccionesNotificacionEmisiones_Melilla

SELECT * 
--DELETE
FROM otInspecciones_Melilla

--*********************************************
--** Ordenes de trabajo: Deshabilitar el trigger **
--DISABLE TRIGGER ordenTrabajo_DeleteCascada ON ordenTrabajo;
--*********************************************
SELECT * 
--DELETE
FROM otDatosValor WHERE otdvOdtCodigo=2001

SELECT * 
--DELETE
FROM ordenTrabajo
WHERE otTipoOrigen='INSPMASIVO'
GO

--*********************************************
--** Ordenes de trabajo: Habilitar el trigger **
--ENABLE TRIGGER ordenTrabajo_DeleteCascada ON ordenTrabajo;
--*********************************************

SELECT *
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones


SELECT * 
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones