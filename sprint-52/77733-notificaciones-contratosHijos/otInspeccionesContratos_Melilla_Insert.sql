ALTER PROCEDURE [dbo].[otInspeccionesContratos_Melilla_Insert]
(
	@CONTRATOGENERAL  VARCHAR(25)=NULL,
	@CONTRATOABONADO  VARCHAR(25)=NULL,
	@ZONA VARCHAR(10)=NULL,
	@Dir_Suministro VARCHAR(250)=NULL,
	@EMPLAZAMIENTO VARCHAR(25)=NULL,
    @INSPECCION INT,
    @UsuarioCarga VARCHAR(10),
    @FechaCarga DATETIME
)
AS

	SET NOCOUNT ON;

	DECLARE @sociedad INT, @serie INT, @otnum INT;
	DECLARE @usrCreated AS VARCHAR(10)='admin', @usrRealizado AS VARCHAR(10);
	DECLARE @ottcod AS VARCHAR(4);
	DECLARE @cotcod AS VARCHAR(6);
	DECLARE @obs VARCHAR(500) = CONCAT('Contrato: ' ,  @CONTRATOABONADO ,  '- Contrato Inspección:  ' ,  @CONTRATOGENERAL);
	DECLARE @otDatosAPTO INT = 2001;
	
	BEGIN TRY
		BEGIN TRAN
		--Si hay registros que no corresponden a la misma carga los borramos
		DELETE
		FROM dbo.otInspeccionesContratos_Melilla
		WHERE INSPECCION = @INSPECCION AND
		(UsuarioCarga<>@UsuarioCarga OR FechaCarga<>@FechaCarga);

		--Para cada inspección se quedan solo los de esta carga.
		INSERT INTO dbo.otInspeccionesContratos_Melilla
		OUTPUT INSERTED.*
		VALUES(@CONTRATOGENERAL, @CONTRATOABONADO, @ZONA, @Dir_Suministro, @EMPLAZAMIENTO, @INSPECCION, @UsuarioCarga, @FechaCarga)
		COMMIT TRAN;
	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
		ROLLBACK TRAN;

		THROW; -- Re-throw the exception
	END CATCH
GO


--SELECT * FROM otInspeccionesContratos_Melilla