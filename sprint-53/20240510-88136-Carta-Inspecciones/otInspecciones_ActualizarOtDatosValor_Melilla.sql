/*
SELECT * 
--UPDATE V SET otdvValor= NULL
--DELETE V
FROM dbo.otDatosValor AS V WHERE otdvOdtCodigo=2001
AND otdvOtNum BETWEEN  51820 AND 51830;
*/

/*
DECLARE @ReturnValue INT;
DECLARE @odtValor AS VARCHAR(25) = NULL--'APTO 100%, NO, SI';
DECLARE @ultimoxservicio BIT = 0;
DECLARE @usuario VARCHAR(10)= 'gmdesousa';

EXEC @ReturnValue = otInspecciones_ActualizarOtDatosValor_Melilla @odtValor, @ultimoxservicio, @usuario ;
SELECT @ReturnValue AS 'Return Value';
*/

ALTER PROCEDURE [dbo].[otInspecciones_ActualizarOtDatosValor_Melilla] 
 @odtValor AS VARCHAR(25) = 'NO', --Esta ejecución actualizará solo las Inspecciones que ahora esten NO-APTAS
 @ultimoxservicio BIT = 1, --1: Si solo queremos actualizar la ultima inspección por tipo / 0: Se revisarán todas las inspecciones	
 @usuario VARCHAR(10)= 'admin'
AS
SET NOCOUNT ON;

DECLARE @OTTIPO_INSPECCION VARCHAR(2) = '02';
DECLARE @CODVALOR INT = 2001;
DECLARE @ahora AS DATETIME = GETDATE();

DECLARE @DATOSVALOR AS dbo.tOtDatosValorApto;
DECLARE @DV_UPDATE AS dbo.tOtDatosValorApto;
DECLARE @VALORES TABLE (valor VARCHAR(10));

--[00]Serían los estados que vamos a re-evaluar para cambiar su estado con la nueva configuración.
INSERT INTO @VALORES
SELECT TRIM(value) FROM STRING_SPLIT(@odtValor, ',');

DECLARE @RESULT INT = 0;

BEGIN TRY
	BEGIN TRAN;

	--[01] Por si se han borrado filas en DatosValor, vamos a insertarlas con valor NULL
	INSERT INTO dbo.otDatosValor
	SELECT I.otiserscd, I.otisercod, I.otinum, @CODVALOR, NULL, 0
	FROM otInspecciones_Melilla AS I
	LEFT JOIN dbo.otDatosValor AS V
	ON  I.otinum = V.otdvOtNum
	AND I.otisercod = V.otdvOtSerCod
	AND I.otiserscd = V.otdvOtSerScd
	AND V.otdvOdtCodigo = @CODVALOR
	WHERE V.otdvOtNum IS NULL;
	
	--************************************************************************
	--[02]Seleccionamos los estados según la configuración actual de TODAS las inspecciones
	DECLARE @xmlApto XML;
	EXEC dbo.otInspecciones_Melilla_DatosValorApto @xmldata = @xmlApto OUTPUT;
	
	INSERT INTO @DATOSVALOR (objectId, Apto)
	SELECT 
    x.value('@objectId', 'INT') AS objectId,
    x.value('@Apto', 'VARCHAR(25)') AS Apto
	FROM @xmlApto.nodes('/otInspeccion') AS t(x);
	
	--***** DEBUG *****
	--SELECT * FROM @DATOSVALOR;

	--************************************************************************
	--[03]@DV_UPDATE: Las que van a entrar en el update
	WITH INSP AS(
	--Seleccionamos las inspecciones y su estado actual
	SELECT I.objectid, I.otinum, I.otisercod, I.otiserscd, I.servicio, I.ctrcod
		 , V.otdvValor
		 , VV.valor
	--RN=1: Para quedarnos con la ultima inspección por contrato
	, RN = ROW_NUMBER() OVER (PARTITION BY I.ctrcod, I.servicio ORDER BY I.fecha_y_hora_de_entrega_efectiv DESC, objectid DESC)
	
	FROM dbo.otInspecciones_Melilla AS I
	LEFT JOIN dbo.otDatosValor AS V
	ON  I.otinum = V.otdvOtNum
	AND I.otisercod = V.otdvOtSerCod
	AND I.otiserscd = V.otdvOtSerScd
	AND V.otdvOdtCodigo = @CODVALOR
	--Estados que queremos reevaluar si han cambiado
	LEFT JOIN @VALORES AS VV
	ON (VV.valor = V.otdvValor OR V.otdvValor= NULL)
	
	), I AS(
	SELECT * FROM INSP  
	--Si queremos centrarnos en actualizar solo la ultima
	WHERE @ultimoxservicio IS NULL OR  @ultimoxservicio=0 OR (@ultimoxservicio=1 AND RN=1))
	
	INSERT INTO @DV_UPDATE
	SELECT D.*
	FROM I
	INNER JOIN @DATOSVALOR AS D
	ON I.objectId = D.objectId
	--Solo actualizaremos los que cambian con la nueva configuracion
	WHERE (@odtValor IS NULL OR I.otdvValor  IS NULL OR I.otdvValor = valor)
	  AND (D.Apto <> ISNULL(I.otdvValor, ''));
	
	--[04]Update de la fecha de actualización en la inspección
	--SELECT *
	UPDATE I SET I.FechaActualizacion = @ahora
	FROM dbo.otInspecciones_Melilla AS I
	INNER JOIN @DV_UPDATE AS D
	ON D.objectID= I.objectid;
	
	--[05] Actualizar el DatosValor
	UPDATE V SET V.otdvValor = D.Apto
	FROM dbo.otInspecciones_Melilla AS I
	INNER JOIN @DV_UPDATE AS D
	ON D.objectID= I.objectid
	INNER JOIN dbo.otDatosValor AS V
	ON  I.otinum = V.otdvOtNum
	AND I.otisercod = V.otdvOtSerCod
	AND I.otiserscd = V.otdvOtSerScd
	AND V.otdvOdtCodigo = @CODVALOR
	

	SET @RESULT = @@ROWCOUNT;

	DECLARE @excCod VARCHAR(10);
	SELECT @excCod = excCod FROM ExcelConsultas 
	WHERE ExcConsulta='[InformesExcel].[otInspecciones_ContratoGeneral_Melilla]';

	IF(@RESULT>0)
		EXEC [dbo].[Task_Schedule_InformesExcel] @usuario, @excCod, @ahora, @ahora, 0;
	
	COMMIT TRAN
	--***** DEBUG *****
	--SELECT @RESULT
	RETURN @RESULT;

END TRY
BEGIN CATCH
	SET @RESULT = 0;
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    	
	THROW;
END CATCH;

GO


