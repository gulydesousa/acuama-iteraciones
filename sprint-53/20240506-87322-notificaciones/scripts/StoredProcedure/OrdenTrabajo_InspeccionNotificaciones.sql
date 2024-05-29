/*
DECLARE @otserscd SMALLINT=1
DECLARE @otsercod SMALLINT=80
DECLARE @otnum INT=47020

EXEC OrdenTrabajo_InspeccionNotificaciones @otserscd, @otsercod, @otnum
*/

ALTER PROCEDURE [dbo].[OrdenTrabajo_InspeccionNotificaciones]
@otserscd SMALLINT, 
@otsercod SMALLINT,
@otnum INT

AS

SELECT V.otinum, V.otisercod, V.otiserscd
, V.correosRef
, V.objectid
, V.ctrcod
, estadoEmision = V.emisionEstado
, estadoID= V.UltimoEstadoId
, estadoNombre = V.UltimoEstado
, estadoFecha = V.UltimoEstadoFecha
, estadoDescripcion = V.otineDescripcion
, estadoEnvioBOE = V.otineEnvioBOE
, estadoEntregaDirecta = V.otineEntregaDirecta
FROM vOtInspeccionesNotificacionEmisiones_Melilla AS V
WHERE V.otiserscd = @otserscd
AND V.otisercod = @otsercod
AND V.otinum = @otnum
--Con esto solo sacamos la información de los contratos que aparecen en la cabecera de la inspeccion
AND (V.RN_ABONADOS IS NULL OR V.RN_ABONADOS<2);

GO


