/*
DECLARE @objectId INT = 3138;
EXEC dbo.otInspecciones_Melilla_DatosValorApto @objectId;
*/
	
ALTER PROCEDURE dbo.otInspecciones_Melilla_DatosValorApto 
@objectId INT=NULL

AS
	SET NOCOUNT ON;

	DECLARE @SQL AS NVARCHAR(MAX);
	DECLARE @DATOS_EVAL AS TABLE(objectId INT, servicio TINYINT, clave VARCHAR(128), valor VARCHAR(250) DEFAULT '', esOK VARCHAR(25) DEFAULT'NO');
	DECLARE @SERVICIOS AS TABLE(servicio TINYINT, [otivColumnas] VARCHAR(MAX), [columns] VARCHAR(MAX));
	DECLARE @servicio TINYINT, @otivColumnas VARCHAR(MAX), @columns VARCHAR(MAX);

	BEGIN TRY

	--********************************************
	--Nos copiamos la técnica de otInspecciones_Melilla_EsApto
	--Pero en este caso la consulta es masiva, es decir, evaluamos todas las inspecciones en un solo tirón
	--********************************************
	--[02] Columnas que se deben evaluar según cada servicio
	INSERT INTO @SERVICIOS
	SELECT [servicio] =  otivServicioCod
		 , [otivColumnas] = STRING_AGG('ISNULL(CAST(' + otivColumna + ' AS VARCHAR), '''') AS ' + otivColumna, ', ') 
		 , [columns] = STRING_AGG(otivColumna, ', ') 			  
	FROM otInspeccionesValidaciones 
	GROUP BY otivServicioCod;

	--********************************************
	--[03]Como la combinación de columnas depende del servicio, debemos iterar: UNPIVOT(columnas a filas) por cada servicio	
	DECLARE SERVICIOS CURSOR FOR 
	SELECT [servicio], [otivColumnas], [columns] FROM @SERVICIOS;
	OPEN SERVICIOS;

	FETCH NEXT FROM SERVICIOS 
	INTO @servicio, @otivColumnas, @columns;

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		--[10]Hacemos UNPIVOT para retornar una fila por cada columna
		SET @SQL = CONCAT(
		'SELECT objectId, servicio, clave, valor, dbo.fOtInspecciones_Melilla_Valor(clave, valor)',
		' FROM (SELECT objectId,', @servicio, ' AS servicio, ', @otivColumnas, 
		' FROM dbo.otInspecciones_Melilla AS I',
		' INNER JOIN otInspeccionesServicios AS S ON S.otisDescripcion=I.servicio', 
		' AND S.otisCod=', @servicio
		, IIF(@objectId IS NULL, '', ' AND objectId =' + CAST(@objectId AS VARCHAR)),
		') AS SourceTable ',
		' UNPIVOT (Valor FOR Clave IN (', @columns, ')) AS UnpivotTable');
	
		--@DATOS_EVAL insertamos todas las columnas en filas.
		INSERT INTO @DATOS_EVAL (objectId, servicio, clave, valor, esOK)
		EXEC sp_executesql @statement = @SQL;

		FETCH NEXT FROM SERVICIOS 
		INTO @Servicio, @otivColumnas, @columns;
	END;

	CLOSE SERVICIOS;
	DEALLOCATE SERVICIOS;
	--********************************************
	
	--[99]Si alguna de las criticas no se cumple, es no-apto
	WITH DATOS_EVAL AS(
	SELECT D.*, V.otivCritica
	, RN= ROW_NUMBER() OVER (PARTITION BY D.objectID ORDER BY V.otivOrden)
	, FaltaValorCritico= SUM(IIF(V.otivCritica=1 AND D.esOK<>'SI', 1, 0)) OVER (PARTITION BY D.objectID)
	, FaltaAlgunValor = SUM(IIF(D.esOK<>'SI', 1, 0)) OVER (PARTITION BY D.objectID)
	FROM @DATOS_EVAL AS D
	LEFT JOIN dbo.otInspeccionesValidaciones AS V
	ON V.otivColumna = D.clave)
	
	SELECT objectId
		 , servicio
		 , Apto = CASE WHEN FaltaAlgunValor=0 THEN 'APTO 100%'
					   WHEN FaltaValorCritico = 0 THEN 'SI'
					   ELSE 'NO' END
	FROM DATOS_EVAL WHERE RN=1;

	END TRY
	BEGIN CATCH
	    -- En caso de error, cerrar y liberar el cursor
		IF CURSOR_STATUS('local', 'SERVICIOS') >= 0
		BEGIN
			CLOSE SERVICIOS;
			DEALLOCATE SERVICIOS;
		END
	END CATCH
GO




	