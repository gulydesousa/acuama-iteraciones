/*
DECLARE @ReturnValue INT;
DECLARE @odtValor AS VARCHAR(25) = NULL;
DECLARE @ultimoxservicio BIT = 0;
DECLARE @usuario VARCHAR(10)= 'gmdesousa';

EXEC @ReturnValue = otInspecciones_ActualizarOtDatosValor_Melilla  @usuario ;
SELECT @ReturnValue AS 'Return Value';
*/

ALTER PROCEDURE [dbo].[otInspecciones_ActualizarOtDatosValor_Melilla] 
 --Parametros opcionales con valores por defecto
 @odtValor AS VARCHAR(25) = 'NO',	-- Default: Solo inspecciones no aptas
 @ultimoxservicio BIT = 1,			-- Default: Ultima inspeccion por servicio 	
 @usuario VARCHAR(10)= 'admin'		-- Default: Usuario admin
AS
SET NOCOUNT ON;

DECLARE @OTTIPO_INSPECCION VARCHAR(2) = '02';
DECLARE @CODVALOR INT = 2001;
DECLARE @ahora AS DATETIME = GETDATE();

DECLARE @DV_NUEVOS AS dbo.tOtDatosValorApto;
DECLARE @DV_UPDATE AS dbo.tOtDatosValorApto;
DECLARE @VALORES TABLE (valor VARCHAR(10));

--Si es blanco o nulo, actualizamos independientemente del estado en el que se encuetre
SET @odtValor = IIF(@odtValor IS NULL OR @odtValor = '', 'SI,NO,APTO 100%' , @odtValor); 
SET @ultimoxservicio = ISNULL(@ultimoxservicio, 0);

INSERT INTO @VALORES
SELECT TRIM(value) FROM STRING_SPLIT(@odtValor, ',');

DECLARE @RESULT INT = 0;

BEGIN TRY
	BEGIN TRAN;

	--[00] Por si se han borrado filas en DatosValor, vamos a insertarlas con valor NULL
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
	--[01] @DV_NUEVOS: Calculamos los estados de TODAS las inspecciones según la configuración actual
	DECLARE @xmlApto XML;
	EXEC dbo.otInspecciones_Melilla_DatosValorApto @xmldata = @xmlApto OUTPUT;
	--*** DEBUG ***
	--SELECT @xmlApto;

	INSERT INTO @DV_NUEVOS (objectId, Apto)
	SELECT 
    x.value('@objectId', 'INT') AS objectId,
    x.value('@Apto', 'VARCHAR(25)') AS Apto
	FROM @xmlApto.nodes('/otInspeccion') AS t(x);
	
	--*** DEBUG ***
	--SELECT '@DV_NUEVOS', * FROM @DV_NUEVOS ORDER BY Apto;
	--SELECT [@odtValor] = @odtValor, [@ultimoxservicio]= @ultimoxservicio, [@usuario]= @usuario;
	--SELECT '@VALORES', * FROM @VALORES;
	
	--************************************************************************
	--[10] @DV_UPDATE: Seleccionamos las que queremos actualizar
	WITH DV_ACTUAL AS(
	--[11]DV_ACTUAL: Seleccionamos las inspecciones y su estado actual
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
	LEFT JOIN @VALORES AS VV
	ON VV.valor = V.otdvValor
	
	), DV_UPDATABLE AS(
	--[12]DV_UPDATABLE: Para quedarnos con una sola por servicio según parametro @ultimoxservicio
	SELECT * FROM DV_ACTUAL  
	--Si queremos centrarnos en actualizar solo la ultima
	WHERE @ultimoxservicio =0 OR (@ultimoxservicio=1 AND RN=1))

	--*** DEBUG ***	
	--SELECT * FROM DV_ACTUAL;
	--SELECT * FROM DV_UPDATABLE;	
	
	--[13]@DV_UPDATE: Las que ha cambiado su estado
	INSERT INTO @DV_UPDATE
	SELECT NEW.*
	FROM DV_UPDATABLE AS OLD
	INNER JOIN @DV_NUEVOS AS NEW
	ON NEW.objectId = OLD.objectId
	--Solo actualizaremos los que deben cambiar
	WHERE OLD.otdvValor IS NULL		 --Por alguna razón se ha perdido el valor en la OT
	OR (OLD.otdvValor <>  NEW.Apto); --Recalcular el valor da un valor diferente
	
	--*** DEBUG ***	
	--SELECT '@DV_UPDATE', * FROM @DV_UPDATE ORDER BY Apto;
	
	--************************************************************************
	--[20]Actualizamos la inspección
	--SELECT I.FechaActualizacion, @ahora, I.objectid
	UPDATE I SET I.FechaActualizacion = @ahora
	FROM dbo.otInspecciones_Melilla AS I
	INNER JOIN @DV_UPDATE AS D
	ON D.objectID= I.objectid;
	
	--[30] Actualizar el DatosValor
	--SELECT V.*, D.Apto
	UPDATE V SET V.otdvValor = D.Apto
	FROM dbo.otInspecciones_Melilla AS I
	INNER JOIN @DV_UPDATE AS D
	ON D.objectID= I.objectid
	INNER JOIN dbo.otDatosValor AS V
	ON  I.otinum = V.otdvOtNum
	AND I.otisercod = V.otdvOtSerCod
	AND I.otiserscd = V.otdvOtSerScd
	AND V.otdvOdtCodigo = @CODVALOR;
	
	--[31] Filas actualizadas
	SET @RESULT = @@ROWCOUNT;

	--[32] Informe con los cambios
	DECLARE @excCod VARCHAR(10);
	SELECT @excCod = excCod FROM ExcelConsultas 
	WHERE ExcConsulta='[InformesExcel].[otInspecciones_ContratoGeneral_Melilla]';

	IF(@RESULT>0)
		EXEC [dbo].[Task_Schedule_InformesExcel] @usuario, @excCod, @ahora, @ahora, 0;
	
	COMMIT TRAN
	RETURN @RESULT;
	
	--*** DEBUG ***	
	--ROLLBACK TRAN
	--SELECT [@RESULT] = @RESULT;
	
END TRY
BEGIN CATCH
	SET @RESULT = 0;
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    	
	THROW;
END CATCH;

GO


