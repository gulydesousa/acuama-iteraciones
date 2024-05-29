/*
SELECT * FROM otInspeccionesValidaciones --41 filas
WHERE otivCritica=1
EXEC otInspeccionesValidaciones_Update @columna='juegollaves', @servicioCod=2, @esCritica= 0, @reqReglamentoCTE=0, @orden=4, @clave='juegollaves',@descripcionCarta='JUEGO DE LLAVE DE ENTRADA Y SALIDA', @esInformativo=1, @valorDefecto='100'
EXEC otInspeccionesValidaciones_Update @columna='juegollavesbat', @servicioCod=1, @esCritica= 0, @reqReglamentoCTE=0, @orden=13, @clave='juegollavesbat',@descripcionCarta='JUEGO DE LLAVE DE ENTRADA Y SALIDA', @esInformativo=1, @valorDefecto='100'
EXEC otInspeccionesValidaciones_Update @columna='calibrebat99', @servicioCod=2, @esCritica= 0, @reqReglamentoCTE=0, @orden=99, @clave='calibrebat',@descripcionCarta='CALIBRES CONTADORES', @esInformativo=1, @valorDefecto='100'
*/

ALTER PROCEDURE [dbo].[otInspeccionesValidaciones_Update]
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
	WHERE otivServicioCod = @servicioCod AND otivColumna <> @columna;

	SET @orden = 
	CASE WHEN @orden IS NULL THEN  @iMax+1
	WHEN @orden>@iMax THEN @iMax+1
	WHEN @orden<0 THEN 0
	ELSE @orden END;

	UPDATE V SET
	otivCritica = @esCritica 
	, otivReqReglamentoCTE = @reqReglamentoCTE
	, otivOrden = @orden
	, otivClave = @clave
	, otivDescParaCartas = @descripcionCarta
	, otivInformativo = ISNULL(@esInformativo, 0)
	, otivValorDefecto = @valorDefecto

	OUTPUT INSERTED.*
	FROM dbo.otInspeccionesValidaciones AS V
	WHERE otivColumna = @columna
	AND otivServicioCod = @servicioCod;
	
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


