/*
DECLARE @diasPlazoD INT = NULL;
DECLARE @diasPlazoH INT = NULL;

--Todas las entregadas
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas
--Entregadas en un plazo
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 0, 2
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 29, 29
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 20, 40
--Entregadas desde
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 29, NULL
--Entregadas hasta
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas NULL, 30
*/
ALTER PROCEDURE [dbo].[otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas]
@diasPlazoD INT = NULL,
@diasPlazoH INT = NULL
AS

WITH ENTREGAS AS(
SELECT [RefCorreos] = notificacionid
, N.objectid
, [CtrGeneral] = N.ctrcod
, [CtrAbonado] = contrato
, DIAS = DATEDIFF(DAY, N.EstadoFecha, GETDATE())
, N.EstadoFecha
, N.FinalPlazo
, N.Estado
, N.NotificadoFecha
--**********************************************************
--Si el contrato tiene representante, hay dos notificaciones
--RN=1 para quedarnos con la ultima notificacion entregada por contrato
, RN = ROW_NUMBER() OVER (PARTITION BY contrato ORDER BY N.NotificadoFecha DESC, notificacionid DESC)
--**********************************************************
FROM vOtInspeccionesNotificacionEdo_Melilla AS N
WHERE N.NotificadoFecha IS NOT NULL) 

SELECT [RefCorreos]
, objectid
, CtrGeneral
, CtrAbonado
, DIAS
, EstadoFecha
, FinalPlazo
, Estado
, NotificadoFecha
FROM ENTREGAS AS E
WHERE RN=1 --#90543: Solo la notificacion mas reciente por contrato
  AND (@diasPlazoD IS NULL OR  E.DIAS>=@diasPlazoD) 
  AND (@diasPlazoH IS NULL OR  E.DIAS<=@diasPlazoH)
  
ORDER BY DIAS, objectid, CtrGeneral, CtrAbonado;
GO


