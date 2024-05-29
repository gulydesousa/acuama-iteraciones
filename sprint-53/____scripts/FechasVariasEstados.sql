SELECT * , (ABS(CHECKSUM(NEWID())) % 15) - 7 AS RandomNumberPerRow

--UPDATE T SET FECHA1 = DATEADD(DAY,  (ABS(CHECKSUM(NEWID())) % 15) - 7 , fecha1)
FROM otInspeccionesNotificacionEdo_Melilla AS T WHERE codigo1=1 AND fecha2 IS NULL

SELECT (ABS(CHECKSUM(NEWID())) % 15) - 7 AS RandomNumberPerRow;

SELECT * FROM votInspeccionesNotificacionEdo_Melilla 
SELECT * FROM otInspeccionesNotificacionEdo_Melilla 

--Todas las entregadas
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas
--Entregadas en un plazo
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 0, 21
--Entregadas hasta
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas NULL, 21


--Entregadas rango
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 22, 23
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 24, 24
--Entregadas desde
EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas 39, NULL

