/*
  SELECT * FROM  OtInspecciones_Melilla WHERE  objectid=3168
  SELECT * FROM  vOtInspecciones_Melilla WHERE objectid=3168
  

*/
ALTER VIEW [dbo].[vOtInspecciones_Melilla] 
AS

WITH PADRES AS(
--Como tenemos que sacar en el informe el padre con los hijos
--Hay casos que el padre es hijo, pero en otros no, 
--Buscamos esos casos para que en nuestra vista siempre traiga el padre con sus hijos
SELECT [CONTRATO GENERAL]
	 , [CONTRATO ABONADO]
	 , [INSPECCION]
	 , [EsHijo]= IIF(SUM(IIF([CONTRATO ABONADO]=[CONTRATO GENERAL], 1, 0)) 
				 OVER(PARTITION BY [CONTRATO GENERAL], [INSPECCION]) > 0, 1, 0) 
	 , [RN] = ROW_NUMBER() 
			  OVER(PARTITION BY [CONTRATO GENERAL], [INSPECCION] 
				   ORDER BY IIF([CONTRATO ABONADO]=[CONTRATO GENERAL], 0, 1), [CONTRATO ABONADO])
FROM otInspeccionesContratos_Melilla

), ICTRS AS(
SELECT [CONTRATO GENERAL], [CONTRATO ABONADO], [INSPECCION] 
FROM otInspeccionesContratos_Melilla
--Trucamos metiendo en el listado de contratos hijos los padres que faltan, asi siempre tenemos el padre con sus hijos
UNION ALL
SELECT [CONTRATO GENERAL], [CONTRATO GENERAL], [INSPECCION] 
FROM PADRES
WHERE EsHijo=0 AND RN=1

--El contrato de la inspeccion lo determina la tabla contratos
), INSP AS(
SELECT I.objectid
, ctrcod = ISNULL(C.[CONTRATO ABONADO], I.ctrcod)
, [CTRCOD_INSPECCION] = I.ctrcod
, Apta = V.otdvValor
, I.fecha_y_hora_de_entrega_efectiv 
, I.servicio
, I.zona
, C.[CONTRATO ABONADO]
, I.otinum, I.otiserscd, I.otisercod
, zonCod = CAST(LTRIM(RTRIM(REPLACE(UPPER(I.zona), 'ZONA',  ''))) AS INT)
--RN=1: Para quedarnos con la inspección mas reciente del contrato
, RN = ROW_NUMBER() OVER (PARTITION BY ISNULL(C.[CONTRATO ABONADO], I.ctrcod) ORDER BY  I.fecha_y_hora_de_entrega_efectiv DESC, objectid DESC)
, CN = COUNT(I.objectid) OVER (PARTITION BY ISNULL(C.[CONTRATO ABONADO], I.ctrcod))
, CHECKED = SUM(IIF(V.otdvValor IN ('SI', 'APTO 100%'), 1, 0)) OVER (PARTITION BY ISNULL(C.[CONTRATO ABONADO], I.ctrcod))
, INSPECCION_GENERAL = IIF(C.[CONTRATO ABONADO] IS NULL OR C.[CONTRATO ABONADO] = I.ctrcod, 1, 0) 
--RN_ABONADOS: Orden que se asigna a los abonados
, RN_ABONADOS = ROW_NUMBER() OVER (PARTITION BY I.objectid ORDER BY C.[CONTRATO ABONADO])
--NUM_ABONADOS: Total de abonados
, NUM_ABONADOS = SUM(IIF(C.[CONTRATO ABONADO]=C.[CONTRATO GENERAL], 0, 1)) OVER (PARTITION BY objectid)
FROM otInspecciones_Melilla AS I 
LEFT JOIN ICTRS AS C
ON I.objectid = C.INSPECCION
INNER JOIN dbo.otDatosValor AS V
ON V.otdvOtSerCod = I.otisercod
AND V.otdvOtSerScd = I.otiserscd
AND V.otdvOtNum = I.otinum)

SELECT I.* 
, E.notificacionid
--Recuperamos el estado actual de la inspección por el numero del contrato
, E.fechaenvioboe
, E.fechapubboe
, UltimoEstadoId = E.EstadoId
, UltimoEstado = E.Estado
, UltimoEstadoFecha = E.EstadoFecha
, E.EntregaDirecta
, E.NotificadoFecha
, E.FinalPlazo
, CambioContadorPermitido = IIF(GETDATE() >= E.FinalPlazo, 1, 0)
, RefIntBOE, NumBOE
FROM INSP AS I
LEFT JOIN dbo.vOtInspeccionesNotificacionEdo_Melilla AS E
ON E.contrato =  I.[CTRCOD_INSPECCION]
AND I.otinum = E.otinum;



GO

