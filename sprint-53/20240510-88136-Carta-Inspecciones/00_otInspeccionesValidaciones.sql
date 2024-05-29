/*
ALTER TABLE dbo.otInspeccionesValidaciones
DROP CONSTRAINT DF_otInspeccionesValidaciones_otivInformativo;
GO 

ALTER TABLE dbo.otInspeccionesValidaciones
DROP COLUMN otivValorDefecto


ALTER TABLE dbo.otInspeccionesValidaciones
DROP COLUMN otivInformativo
GO 
*/

ALTER TABLE dbo.otInspeccionesValidaciones
ADD otivInformativo BIT CONSTRAINT DF_otInspeccionesValidaciones_otivInformativo DEFAULT 0 NOT NULL;
GO

ALTER TABLE dbo.otInspeccionesValidaciones
ADD otivValorDefecto VARCHAR(250);
GO


EXEC sp_rename 'otInspeccionesValidaciones.otivDescripcion', 'otivDescParaCartas', 'COLUMN';
GO

SELECT * FROM otInspeccionesValidaciones;


SELECT * FROM otInspeccionesNotificacionEmisiones_Melilla
SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones

SELECT DISTINCT emisionID FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones