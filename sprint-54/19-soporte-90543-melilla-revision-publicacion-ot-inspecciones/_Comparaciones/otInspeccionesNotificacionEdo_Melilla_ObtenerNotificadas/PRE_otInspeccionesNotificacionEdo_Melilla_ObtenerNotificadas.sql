USE [ACUAMA_MELILLA_PRE]
GO

/****** Object:  StoredProcedure [dbo].[otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas]    Script Date: 04/06/2024 15:49:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
CREATE PROCEDURE [dbo].[otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas]
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


