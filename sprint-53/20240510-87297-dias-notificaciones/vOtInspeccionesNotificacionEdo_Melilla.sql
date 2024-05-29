--SELECT * FROM vOtInspeccionesNotificacionEdo_Melilla

ALTER VIEW [dbo].[vOtInspeccionesNotificacionEdo_Melilla]
AS
/*
Lo que nos han pedido es calcular fecha de OT +21 fecha exitosa de notificación, en unos casos será el primer intento, en otros el segundo y en otro la de publicación en el BOE.
En los casos en los que se haya notificado exitosamente en uno de los dos primeros intentos a través de la empresa de notificaciones, la fecha final es la de referencia +21 para generar la OT. 
En el caso de que no se haya notificado y sea necesaria la publicación en el BOE la fecha para generar la OT es la fecha de publicación en BOE +21.
*/

--[01]FECHAS: Seleccionamos una fila por cada fecha con estado de notificacion
WITH FECHAS AS(
SELECT notificacionid, contrato, ot_inspeccion, fechaenvioboe, fechapubboe, RefIntBOE, NumBOE
, fecha = fecha1
, estado = codigo1
, indice = 1
FROM [dbo].[otInspeccionesNotificacionEdo_Melilla] 
WHERE fecha1 IS NOT NULL AND codigo1 IS NOT NULL

UNION ALL
SELECT notificacionid, contrato, ot_inspeccion, fechaenvioboe, fechapubboe, RefIntBOE, NumBOE
, fecha = fecha2
, estado = codigo2
, indice = 2
FROM [dbo].[otInspeccionesNotificacionEdo_Melilla] 
WHERE fecha2 IS NOT NULL AND codigo2 IS NOT NULL

UNION ALL
SELECT notificacionid, contrato, ot_inspeccion, fechaenvioboe, fechapubboe, RefIntBOE, NumBOE
, fecha = fechaoficina
, estado = codigooficina
, indice = 3
FROM [dbo].[otInspeccionesNotificacionEdo_Melilla] WHERE fechaoficina IS NOT NULL AND codigooficina IS NOT NULL

--[02]F: Ordenamos por fecha
), F AS(
SELECT *
--RN=1: Para quedarnos con la fecha mas reciente
, RN = ROW_NUMBER() OVER (PARTITION BY notificacionid ORDER BY fecha DESC, indice DESC)
FROM FECHAS

), F1 AS(
--Para quedarnos con la fecha mas reciente
SELECT * FROM F WHERE RN=1)

SELECT  F1.notificacionid, F1.contrato,  F1.ot_inspeccion
--Convertimos las fechas a DATE (sin time)
, fechaenvioboe = CAST(F1.fechaenvioboe AS DATE)
, fechapubboe	= CAST(F1.fechapubboe AS DATE)
, indice
--Información de los estados
, EstadoId			= F1.estado
, Estado			= E.otineNombre
, EstadoFecha		= CAST(F1.fecha AS DATE)
, EntregaDirecta	= E.otineEntregaDirecta --1: Papel en mano del cliente
, BOE				= IIF(F1.estado=3 AND indice>=2, 1,  E.otineEnvioBOE) --3:Ausente, se envia al boe si es el segundo intento
--NotificadoFecha: Fecha en la que se da por notificado el cliente, bien sea por correo en mano o BOE
, NotificadoFecha	= CAST(IIF(E.otineEntregaDirecta= 1, F1.fecha, F1.fechapubboe) AS DATE)
--+21 dias que vienen del parametro INSPECCION_NOTIF_DIAS
, FinalPlazo		= CAST(DATEADD(DAY, CAST(ISNULL(P.pgsvalor, '21') AS INT)
							, CASE WHEN E.otineEntregaDirecta= 1 THEN fecha --Se entrega en mano al cliente							
								   ELSE F1.fechapubboe END) AS DATE)		--Se ha notificado por BOE
, F1.RefIntBOE, F1.NumBOE
, I.objectid
, I.otinum, I.otisercod, I.otiserscd
, I.ctrcod
FROM F1
LEFT JOIN dbo.otInspeccionesNotificacionEstados AS E 
ON E.otineCodigo = F1.estado
LEFT JOIN dbo.parametros AS P 
ON P.pgsclave='INSPECCION_NOTIF_DIAS'
--Enlazamos por el numero de OT para recuperar el objectID
INNER JOIN dbo.otInspecciones_Melilla AS I
ON  I.otinum = F1.ot_inspeccion;
GO


