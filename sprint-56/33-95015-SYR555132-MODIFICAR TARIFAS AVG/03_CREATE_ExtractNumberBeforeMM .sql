/*
-- Ejemplo de uso
SELECT AVG.ExtractNumberBeforeMM('CUOTA CONTRATACION (300 MM)') AS ExtractedNumber;
SELECT AVG.ExtractNumberBeforeMM('C.SERVICIO  50MM') AS ExtractedNumber;
SELECT AVG.ExtractNumberBeforeMM('FIANZA CONSTITUIDA (50+MM) - BOP 11') AS ExtractedNumber;
*/

CREATE FUNCTION [AVG].ExtractNumberBeforeMM (@inputText NVARCHAR(MAX))
RETURNS INT
AS
BEGIN
    DECLARE @posMM INT;
    DECLARE @startPos INT;
    DECLARE @length INT;
    DECLARE @number NVARCHAR(MAX);
    DECLARE @i INT;

    -- Inicializar la posici�n de b�squeda
    SET @posMM = CHARINDEX('MM', @inputText);

    -- Si no se encuentra "MM", devolver NULL
    IF @posMM = 0
        RETURN NULL;

    -- Buscar hacia atr�s desde "MM" para encontrar el inicio del n�mero
    SET @i = @posMM - 1;
    WHILE @i > 0 AND SUBSTRING(@inputText, @i, 1) NOT LIKE '[0-9]'
    BEGIN
        SET @i = @i - 1;
    END

    -- La posici�n inicial del n�mero es @i
    SET @startPos = @i;

    -- Buscar el inicio del n�mero
    WHILE @startPos > 0 AND SUBSTRING(@inputText, @startPos, 1) LIKE '[0-9]'
    BEGIN
        SET @startPos = @startPos - 1;
    END

    -- Ajustar la posici�n inicial del n�mero
    SET @startPos = @startPos + 1;

    -- La longitud del n�mero es la diferencia entre @i y @startPos + 1
    SET @length = @i - @startPos + 1;

    -- Extraer el n�mero
    SET @number = SUBSTRING(@inputText, @startPos, @length);

    -- Eliminar caracteres no num�ricos del final del n�mero
    WHILE LEN(@number) > 0 AND RIGHT(@number, 1) NOT LIKE '[0-9]'
    BEGIN
        SET @number = LEFT(@number, LEN(@number) - 1);
    END

    -- Convertir a INT y devolver si es un n�mero v�lido
    IF ISNUMERIC(@number) = 1
        RETURN CAST(@number AS INT);

    -- Si no se encuentra un n�mero v�lido, devolver NULL
    RETURN NULL;
END;
GO