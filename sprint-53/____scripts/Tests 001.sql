SELECT * 
--DELETE
FROM otInspeccionesContratos_Melilla

SELECT * 
--DELETE
FROM otInspecciones_Melilla


SELECT *
--DELETE
FROM otInspeccionesNotificacionEdo_Melilla

SELECT *
--DELETE
FROM Task_Schedule WHERE tskUser='gmdesousa' AND tskNumber=1


SELECT *
--delete
FROM otInspeccionesNotificacionEdo_Melilla

--DISABLE TRIGGER ordenTrabajo_DeleteCascada ON ordenTrabajo;
SELECT * 
--DELETE
FROM otDatosValor WHERE otdvOdtCodigo=2001

select * 
--DELETE
from ordenTrabajo
where otTipoOrigen='INSPMASIVO'
GO

--ENABLE TRIGGER ordenTrabajo_DeleteCascada ON ordenTrabajo;

--EMISIONES
--DBCC CHECKIDENT ('otInspeccionesNotificacionEmisiones_Melilla', RESEED, 0);
SELECT * 
--DELETE
FROM otInspeccionesNotificacionEmisiones_Melilla

SELECT *
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones

--DBCC CHECKIDENT ('ReportingServices.TO039_EmisionNotificaciones_Emisiones', RESEED, 0);
SELECT * 
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones
