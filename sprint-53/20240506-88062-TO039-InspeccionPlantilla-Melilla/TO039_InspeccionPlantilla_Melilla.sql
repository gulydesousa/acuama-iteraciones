/*
--DECLARE @objectid AS INT = 3138;
DECLARE @objectid AS INT = 3098;


EXEC [ReportingServices].[TO039_InspeccionPlantilla_Melilla] @objectid

SELECT * FROM otInspecciones_Melilla
*/
ALTER PROCEDURE [ReportingServices].[TO039_InspeccionPlantilla_Melilla] @objectid AS INT
AS
	
	DECLARE @DATOS AS TABLE(Clave  VARCHAR(250), Valor VARCHAR(250) DEFAULT '', Columna VARCHAR(250));
	DECLARE @DATOS_EVAL AS TABLE(Orden SMALLINT, Descripcion VARCHAR(250), Columna VARCHAR(128), Valor VARCHAR(250) DEFAULT '', esOK VARCHAR(2), esCritico VARCHAR(2), clave VARCHAR(250));

	INSERT INTO @DATOS(Clave, Valor, Columna)
	EXEC otInspecciones_Melilla_ObtenerDatos @objectid=@objectid ;

	
	--Si es apto, vamos a ver si es apto al 100%
	INSERT INTO @DATOS_EVAL(Orden, Descripcion, Columna, Valor, esCritico, esOK, clave)
	SELECT V.otivOrden
		 , V.otivDescripcion
		 , V.otivColumna
		 , Valor
		 , V.otivCritica
		, esOK = dbo.fOtInspecciones_Melilla_Valor(V.otivColumna, D.Valor)
		, V.otivClave
	FROM otInspecciones_Melilla AS I
	INNER JOIN  dbo.otInspeccionesServicios AS S
	ON I.servicio = S.otisDescripcion
	INNER JOIN dbo.otInspeccionesValidaciones AS V
	ON V.otivServicioCod = S.otisCod
	LEFT JOIN @DATOS AS D
	ON  V.otivColumna = D.Columna 
	WHERE objectid=@objectid;
	
	WITH RESULT AS(
	SELECT *
	--Contamos cuantas lineas se incumplen por Validacion
	, [No-CumpleRequisito] = SUM(IIF(esOK<>'SI', 1, 0)) OVER(PARTITION BY  clave) 
	, RN = ROW_NUMBER() OVER(PARTITION BY  clave ORDER BY orden, Descripcion DESC)
	FROM @DATOS_EVAL) 

	SELECT Orden, Descripcion, Columna=clave, Valor, esOK, esCritico
	, [CumpleRequisito] = IIF([No-CumpleRequisito]>0, 'NO', 'SI')
	FROM RESULT
	WHERE RN=1
	ORDER BY Orden;

GO


