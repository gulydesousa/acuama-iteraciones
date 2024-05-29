SELECT * FROM otInspeccionesValidaciones ORDER BY otivServicioCod, otivOrden

SELECT objectid, servicio, ctrcod, calibrebat, arquetaconpuerta,arquetafachada,arquetanivelsuelo 
FROM otInspecciones_Melilla 
WHERE UsuarioCarga= 'gmdesousa' order by ctrcod

SELECT *
FROM otInspeccionesContratos_Melilla 
WHERE UsuarioCarga= 'gmdesousa' 



SELECT objectid, ctrcod, calibrebat 
--UPDATE C SET calibrebat=NULL
FROM otInspecciones_Melilla AS C WHERE UsuarioCarga= 'gmdesousa' AND objectid='3321'

SELECT * FROM otInspeccionesNotificacionEdo_Melilla

--Fecha emision -30 DIAS
SELECT * 
--UPDATE E SET fecha= DATEADD(DAY, -30, fecha)
FROM [ReportingServices].[TO039_EmisionNotificaciones_Emisiones] AS E
WHERE usuario='gmdesousa' 

SELECT notificacion= ROW_NUMBER() OVER (ORDER BY CONTRATO, emisionEstado) + 900
, CONTRATO
, otNum
, fecha1 = CAST (DATEADD(DAY, 1, E.fecha) AS DATE)
  ,  CASE 
        WHEN FLOOR(RAND(CHECKSUM(NEWID())) * 6) + 1 > 1 THEN 1
        ELSE FLOOR(RAND(CHECKSUM(NEWID())) * 6) + 1
    END AS RandomNumber
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones  AS N
LEFT JOIN ReportingServices.TO039_EmisionNotificaciones_Emisiones AS E
ON N.emisionID = E.emisionID
WHERE N.emisionID IN (9, 10)

