--SELECT * FROM vOtInspeccionesNotificacionEmisiones_Melilla WHERE ctrcod =29293
--SELECT * FROM vOtInspeccionesNotificacionEmisiones_Melilla WHERE ctrcod =4730

ALTER VIEW [dbo].[vOtInspeccionesNotificacionEmisiones_Melilla] 
AS
	WITH ENVIOS AS(
	SELECT objectid = O.otineObjectID 
	, countEnvios = SUM(IIF(O.otineEmisionEstado='Emitir', 1, 0))
	, fechaUltEnvio = MAX(E.[fecha])
	, contrato = MAX(otineCtrCod)
	, titular = MAX(IIF(otineEmisionEstado='Emitir', otineTitCod, ''))
	, representante = MAX(IIF(otineEmisionEstado<>'Emitir', otineCtrRepresent, ''))
	
	FROM dbo.otInspeccionesNotificacionEmisiones_Melilla AS O
	INNER JOIN ReportingServices.TO039_EmisionNotificaciones_Emisiones AS E
	ON O.otineEmision = E.emisionID
	INNER JOIN otInspecciones_Melilla AS I
	ON I.objectid = O.otineObjectID
	GROUP BY O.otineObjectID , O.otineCtrCod
	
	), PARAMETRO AS(
	SELECT maxIntentos= IIF(ISNUMERIC(pgsvalor)= 1, 	CAST(pgsvalor AS INT), 1)
	FROM dbo.parametros AS P
	WHERE P.pgsclave = 'INSPECCION_NOTIF_INTENTOS')

	SELECT I.objectid, I.CTRCOD_INSPECCION, I.ctrcod, I.otinum, I.otisercod, I.otiserscd, I.servicio, I.zonCod, I.Apta, I.zona
	--, P.maxIntentos
	, E.countEnvios, E.fechaUltEnvio
	, E.titular, E.representante
	, I.RefIntBOE, I.NumBOE
	, I.fechaenvioboe, I.fechapubboe
	, I.EntregaDirecta
	, I.UltimoEstadoId, I.UltimoEstado, I.UltimoEstadoFecha
	, I.NotificadoFecha, I.FinalPlazo 
	, [correosRef] = I.notificacionid --referencia asignada por correos a la notificacion
	, EE.otineDescripcion
	, EE.otineEnvioBOE
	, EE.otineEntregaDirecta
	, I.RN_ABONADOS
	--Cualquier cambio en esta columna debe reflejarse luego en el 
	--C#: cOtInspeccionesNotificacionBO
	--Se emitirán solo las que tienen emision = 0
	, emisionEstado = CASE	--El cliente (o el titular) ya están notificados (en papel 1, 8)
							WHEN MAX(CAST(EntregaDirecta AS SMALLINT)) OVER (PARTITION BY  I.objectid, I.ctrcod) = 1 
							THEN 'Notificado'
							--No emitir: Pendiente enviar al "listado-boe"
							WHEN I.UltimoEstadoId IN (2, 4, 5, 6, 7) 
							THEN 'Pendiente enviar a Listado BOE'
							--No emitir: Ya está publicado en el BOE
							WHEN I.UltimoEstadoId IN (9) AND  fechapubboe IS NOT NULL
							THEN 'Publicado en BOE'
							--No emitir: Ya está envado al BOE
							WHEN I.UltimoEstadoId IN (9) AND  fechaenvioboe IS NOT NULL
							THEN 'Enviado al BOE'
							--No emitir: Ya está en el "listado-boe"
							WHEN I.UltimoEstadoId IN (9) 
							THEN 'En Listado BOE'
							 --No emitir: se ha alcanzado el máximo
							WHEN (E.countEnvios>= maxIntentos)	
							THEN 'Maximo Intentos Alcanzado'	
							--No emitir: La ultima notificación aún no tiene respuesta
							WHEN (E.countEnvios IS NOT NULL AND (I.UltimoEstadoFecha IS NULL OR I.UltimoEstadoFecha < E.fechaUltEnvio))  
							THEN 'Esperando Estado de la Entrega'
							--Se puede emitir
							ELSE 'Emitir' END
	FROM dbo.vOtInspecciones_Melilla AS I
	LEFT JOIN ENVIOS AS E
	ON  E.objectid = I.objectid
	AND E.contrato = I.ctrcod
	LEFT JOIN dbo.otInspeccionesNotificacionEstados AS EE
	ON EE.otineCodigo = I.UltimoEstadoId
	CROSS JOIN PARAMETRO AS P
	--Con esto solo sacamos la información de los contratos que aparecen en la cabecera de la inspeccion
	--WHERE I.RN_ABONADOS IS NULL OR I.RN_ABONADOS IN(1, 0)

GO


