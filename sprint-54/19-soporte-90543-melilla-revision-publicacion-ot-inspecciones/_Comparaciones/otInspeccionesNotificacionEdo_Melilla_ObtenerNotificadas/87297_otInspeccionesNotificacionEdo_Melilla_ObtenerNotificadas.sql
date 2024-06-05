
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
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 21, NULL
--Entregadas hasta
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas NULL, 30
*/
ALTER PROCEDURE otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas
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
FROM vOtInspeccionesNotificacionEdo_Melilla AS N
WHERE N.NotificadoFecha IS NOT NULL

) SELECT * 
FROM ENTREGAS AS E
WHERE (@diasPlazoD IS NULL OR  E.DIAS>=@diasPlazoD) 
  AND (@diasPlazoH IS NULL OR  E.DIAS<=@diasPlazoH)
  
ORDER BY DIAS, objectid, CtrGeneral, CtrAbonado;
GO
