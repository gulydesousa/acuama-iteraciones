ALTER PROCEDURE [dbo].[otInspeccionesServicios_Delete]
@columna VARCHAR(128)=NULL,
@servicioCod TINYINT=NULL,
@esCritica BIT=NULL, 
@reqReglamentoCTE BIT=NULL, 
@orden TINYINT = NULL,
@descripcion VARCHAR(250) = NULL,
@descripcionCarta VARCHAR(250) = NULL
AS
	--TODO: Cambiar en el C# la llamada a este sp por otInspeccionesValidaciones_Delete
	EXEC dbo.otInspeccionesValidaciones_Delete @columna, @servicioCod, @esCritica, @reqReglamentoCTE, @orden, @descripcion, @descripcionCarta;

GO


