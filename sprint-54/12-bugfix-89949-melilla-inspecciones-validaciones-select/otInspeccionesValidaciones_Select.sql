/*
SELECT * FROM otInspeccionesValidaciones --41 filas

exec otInspeccionesValidaciones_Select @clave='arqueta'
exec otInspeccionesValidaciones_Select @columna='tecnicas_bat_1'
exec otInspeccionesValidaciones_Select @columna='%tecnicas_bat_1%'
exec otInspeccionesValidaciones_Select @servicioCod=2
*/

ALTER PROCEDURE [dbo].[otInspeccionesValidaciones_Select]
@servicioCod INT = NULL,
@columna VARCHAR(128) = NULL,
@esCritica BIT = NULL,
@reqReglamentoCTE BIT = NULL,
@orden TINYINT = NULL,
@descripcionCarta VARCHAR(250) = NULL,
@clave VARCHAR(250) = NULL,
@esInformativo BIT = NULL,
@valorDefecto VARCHAR(250) = NULL

AS
SET NOCOUNT ON;

SET @clave = UPPER(CONCAT('%', LTRIM(RTRIM(@clave)), '%'));
SET @descripcionCarta = UPPER(CONCAT('%', LTRIM(RTRIM(@descripcionCarta)), '%'));
SET @valorDefecto = UPPER(CONCAT('%', LTRIM(RTRIM(@valorDefecto)), '%'));

SET @columna = LTRIM(RTRIM(@columna));

SELECT I.*, S.*
FROM dbo.otInspeccionesValidaciones AS I
LEFT JOIN dbo.otInspeccionesServicios AS S
ON S.otisCod = I.otivServicioCod
--En las dos columnas PK (Servicio, Columna) la comparacion debe ser de igualdad
WHERE (@servicioCod IS NULL OR I.otivServicioCod=@servicioCod)
AND (@columna IS NULL OR @columna='' OR  I.otivColumna = @columna)
--*****************************************************************
AND (@esCritica IS NULL OR I.otivCritica=@esCritica)
AND (@reqReglamentoCTE IS NULL OR I.otivReqReglamentoCTE=@reqReglamentoCTE)
AND (@orden IS NULL OR I.otivOrden>=@orden)
AND (@clave IS NULL OR UPPER(ISNULL(I.otivClave, '')) LIKE @clave)
AND (@descripcionCarta IS NULL OR UPPER(ISNULL(I.otivDescParaCartas, '')) LIKE @descripcionCarta)
AND (@esInformativo IS NULL OR otivInformativo = @esInformativo)
AND (@valorDefecto IS NULL OR UPPER(ISNULL(I.otivValorDefecto , '')) LIKE @valorDefecto)

ORDER BY I.otivServicioCod, I.otivOrden,I.otivClave, I.otivDescParaCartas DESC;

GO


