/*
SELECT * FROM otInspeccionesValidaciones
EXEC otInspeccionesValidaciones_Insert @columna='calibrebat99', @servicioCod=2, @esCritica= 0, @reqReglamentoCTE=0, @orden=99, @clave='calibrebat',@descripcionCarta='CALIBRES CONTADORES', @esInformativo=1, @valorDefecto='99'
*/

ALTER PROCEDURE [dbo].[otInspeccionesValidaciones_Insert]
@columna VARCHAR(128),
@servicioCod TINYINT,
@esCritica BIT=NULL, 
@reqReglamentoCTE BIT=NULL, 
@orden TINYINT = NULL,
@clave VARCHAR(250) = NULL,
@descripcionCarta VARCHAR(250) = NULL,
@esInformativo BIT = NULL,
@valorDefecto VARCHAR(250) = NULL
AS
SET NOCOUNT ON;

BEGIN TRY

	BEGIN TRAN
	DECLARE @iMax INT = 0;
	
	SELECT @iMax = MAX(otivOrden) 
	FROM  dbo.otInspeccionesValidaciones AS V
	WHERE otivColumna = @columna
	AND otivServicioCod = @servicioCod;

	SET @orden = 
	CASE WHEN @orden IS NULL THEN  @iMax+1
	WHEN @orden>@iMax THEN @iMax+1
	WHEN @orden<0 THEN 0
	ELSE @orden END;

	INSERT INTO dbo.otInspeccionesValidaciones(otivColumna, otivServicioCod, otivCritica, otivReqReglamentoCTE, otivOrden, otivClave, otivDescParaCartas, otivInformativo, otivValorDefecto )
	OUTPUT INSERTED.*
	VALUES (@columna, @servicioCod, @esCritica, @reqReglamentoCTE, @orden, @clave, @descripcionCarta, @esInformativo, @valorDefecto);
	
	COMMIT TRAN
END TRY
BEGIN CATCH
	-- Si ocurre una excepción, se hace rollback a la transacción
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;
	-- Luego, se devuelve la excepción
	THROW;
END CATCH
GO


