--DELETE FROM otInspeccionesContratos_Melilla

ALTER TABLE dbo.otInspeccionesContratos_Melilla
ADD oticserscd SMALLINT NOT NULL,
	oticsercod SMALLINT NOT NULL,
	oticnum INT NOT NULL;
GO

ALTER TABLE [dbo].[otInspeccionesContratos_Melilla] 
ADD CONSTRAINT [FK_otInspeccionesContratos_ot] 
FOREIGN KEY([oticserscd], [oticsercod], [oticnum])
REFERENCES [dbo].[ordenTrabajo] ([otserscd], [otsercod], [otnum])
GO




