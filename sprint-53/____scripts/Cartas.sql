SELECT ctrcod, [OT]= otinum, objectid,
llavepaso,
tuberiaentrada,
arquetaconpuerta,
juegollaves,
valvularetencion,
tamanoroscae,
tamanoroscas,
estadocontador
FROM otInspecciones_Melilla WHERE ctrcod=2163 AND otinum=47051

EXEC ReportingServices.TO039_InspeccionPlantilla_Melilla 3138

SELECT M.*, otdvValor FROM votInspecciones_Melilla AS M
LEFT JOIN otDatosValor
ON otdvOtNum = otinum
order by CAST(ctrcod AS INT)

--SELECT * FROM otInspecciones_Melilla

DECLARE @objectid AS INT = 3138;
/*
EXEC [ReportingServices].[TO039_InspeccionPlantilla_Melilla] @objectid

CREATE PROCEDURE [ReportingServices].[TO039_InspeccionPlantilla_Melilla] @objectid AS INT
AS
*/	
	DECLARE @DATOS AS TABLE(Columna  VARCHAR(250), Valor VARCHAR(250) DEFAULT '');
	DECLARE @DATOS_EVAL AS TABLE(Orden SMALLINT, Descripcion VARCHAR(350), Columna VARCHAR(128), Valor VARCHAR(250) DEFAULT '', esOK VARCHAR(2), esCritico VARCHAR(2));

	INSERT INTO @DATOS(Columna, Valor)
	EXEC otInspecciones_Melilla_ObtenerDatos @objectid=@objectid ;

	SELECT * FROM @DATOS;
	
	--Si es apto, vamos a ver si es apto al 100%
	INSERT INTO @DATOS_EVAL(Orden, Descripcion, Columna, Valor, esCritico, esOK)
	
	SELECT V.otivOrden, IIF(otivDescParaCartas IS NULL OR otivDescParaCartas='', V.otivDesc, V.otivDescParaCartas)
		 , V.otivColumna
		 , Valor
		 , V.otivCritica
		, esOK = CASE 
			WHEN D.Valor IS NULL THEN 'NO' --Si el valor no esta informado NO es valido				
			WHEN D.Valor IN ('SI', 'NO') THEN D.Valor								
			WHEN D.Valor IN ('MALO') THEN 'NO'												
			WHEN LEN(D.Valor) > 0 THEN 'SI' --Otro tipo lo consideramos válido si tiene valor asiganado
			ELSE 'NO' END 
	FROM otInspecciones_Melilla AS I
	INNER JOIN  dbo.otInspeccionesServicios AS S
	ON I.servicio = S.otisDescripcion
	INNER JOIN dbo.otInspeccionesValidaciones AS V
	ON V.otivServicioCod = S.otisCod
	LEFT JOIN @DATOS AS D
	ON  V.otivColumna = D.Columna 
	WHERE objectid=@objectid;
	
	SELECT * FROM @DATOS_EVAL ORDER BY Orden;
GO
