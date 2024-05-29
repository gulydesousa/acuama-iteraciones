--SELECT * FROM  vOtInspeccionesAptas_Melilla ORDER BY objectid, MOCK DESC, ctrcod
--SELECT * FROM otInspecciones_Melilla WHERE otinum=30426
--SELECT * FROM  vOtInspeccionesAptas_Melilla WHERE ctrcod=3229
ALTER VIEW [dbo].[vOtInspeccionesAptas_Melilla] 
AS

WITH CTRS AS(
--Contratos Hijos
SELECT C.[CONTRATO GENERAL]
, C.[CONTRATO ABONADO]
, C.ZONA
, C.[Dir. Suministro]
, C.EMPLAZAMIENTO
, C.INSPECCION
, CN = SUM(IIF(C.[CONTRATO GENERAL] = C.[CONTRATO ABONADO], 1, 0)) OVER(PARTITION BY C.INSPECCION)
, RN = ROW_NUMBER() OVER(PARTITION BY C.INSPECCION ORDER BY IIF(C.[CONTRATO GENERAL]=C.[CONTRATO ABONADO], 0, 1), C.[CONTRATO ABONADO])
FROM dbo.otInspeccionesContratos_Melilla AS C

), PADRES AS (
--Contratos padres que faltan en el arbol de hijos
SELECT [CONTRATO GENERAL] = I.ctrcod
, [CONTRATO ABONADO] = I.ctrcod
, [ZONA] = I.zona
, [Dir. Suministro] = I.domicilio
, [EMPLAZAMIENTO] = C.EMPLAZAMIENTO
, [INSPECCION] = C.INSPECCION
FROM CTRS AS C
INNER JOIN dbo.otInspecciones_Melilla AS I
ON C.INSPECCION = I.objectid
WHERE CN=0    
AND RN=1

), CONTRATOS AS(
SELECT [CONTRATO GENERAL],[CONTRATO ABONADO], ZONA, [Dir. Suministro], EMPLAZAMIENTO, INSPECCION, [MOCK]=1 FROM PADRES
UNION ALL
SELECT [CONTRATO GENERAL],[CONTRATO ABONADO], ZONA, [Dir. Suministro], EMPLAZAMIENTO, INSPECCION, [MOCK]=0 FROM CTRS)

SELECT  I.objectid
, ctrcod = ISNULL(C.[CONTRATO ABONADO], I.ctrcod)
, I.contrato
, V.otdvValor
, C.[CONTRATO ABONADO]
, C.MOCK
, I.fecha_y_hora_de_entrega_efectiv 
--RN=1: para quedarnos con la última inspeccion de cada contrato
, RN = ROW_NUMBER() OVER (PARTITION BY ISNULL(C.[CONTRATO ABONADO], I.ctrcod) ORDER BY  I.fecha_y_hora_de_entrega_efectiv DESC)
FROM dbo.otInspecciones_Melilla AS I
INNER JOIN dbo.otDatosValor AS V
ON  V.otdvOtSerCod = I.otisercod
AND V.otdvOtSerScd = I.otiserscd
AND V.otdvOtNum = I.otinum
AND V.otdvOdtCodigo = 2001
LEFT JOIN CONTRATOS AS C
ON C.INSPECCION =I.objectid;

GO

