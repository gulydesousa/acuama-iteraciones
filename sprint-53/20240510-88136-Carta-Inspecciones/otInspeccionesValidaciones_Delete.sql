/*
EXEC otInspeccionesValidaciones_Delete @columna = 'calibrebat99'
*/


ALTER PROCEDURE [dbo].[otInspeccionesValidaciones_Delete]
@columna VARCHAR(128)=NULL,
@servicioCod TINYINT=NULL,
@esCritica BIT=NULL, 
@reqReglamentoCTE BIT=NULL, 
@orden TINYINT = NULL,
@clave VARCHAR(250) = NULL,
@descripcionCarta VARCHAR(250) = NULL,
@esInformativo BIT = NULL
AS
	SET NOCOUNT ON;
	DELETE 	V
	FROM dbo.otInspeccionesValidaciones AS V
	WHERE (@columna IS NULL OR otivColumna = @columna)
	AND (@servicioCod IS NULL OR otivServicioCod = @servicioCod)
	AND (@esCritica IS NULL OR otivCritica = @esCritica)
	AND (@reqReglamentoCTE IS NULL OR otivReqReglamentoCTE = @reqReglamentoCTE)
	AND (@orden IS NULL OR otivOrden = @orden)
	AND (@clave IS NULL OR otivClave = @clave)
	AND (@descripcionCarta IS NULL OR otivDescParaCartas = @descripcionCarta)
	AND (@esInformativo IS NULL OR otivInformativo = @esInformativo);	
GO


