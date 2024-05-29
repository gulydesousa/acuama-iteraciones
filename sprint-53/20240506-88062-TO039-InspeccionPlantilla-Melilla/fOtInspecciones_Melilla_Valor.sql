CREATE FUNCTION dbo.fOtInspecciones_Melilla_Valor
( @Columna VARCHAR(250)
, @Valor VARCHAR(250))
RETURNS VARCHAR(25)
AS
BEGIN
	--Evalua el valor y en función de lo que sea retorna SI o NO
	RETURN
	CASE 
		WHEN @Valor IS NULL THEN 'NO' --Si el valor no esta informado NO es valido				
		WHEN @Valor IN ('SI', 'NO') THEN @Valor								
		WHEN @Valor IN ('MALO') THEN 'NO'												
		WHEN LEN(@Valor) > 0 THEN 'SI' --Otro tipo lo consideramos válido si tiene valor asiganado
		ELSE 'NO' END 
END