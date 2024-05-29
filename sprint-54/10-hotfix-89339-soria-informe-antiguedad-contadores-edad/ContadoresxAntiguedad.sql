/*

INSERT INTO ExcelConsultas VALUES(
  '000/021'	
, 'Contadores por Antiguedad'	
, 'Contadores por Antiguedad (edad en años)'
, '19'
, '[InformesExcel].[ContadoresxAntiguedad]'
, 'CSV'
, 'Contadores actualmente instalados con una edad minima.'
)

INSERT INTO ExcelPerfil VALUES('000/021', 'root', 3, NULL)
INSERT INTO ExcelPerfil VALUES('000/021', 'jefAdmon', 3, NULL)
INSERT INTO ExcelPerfil VALUES('000/021', 'jefeExp', 3, NULL)
*/

/*
DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><valor></valor><zonaD></zonaD><zonaH></zonaH></LI></NodoXML>';

EXEC [InformesExcel].[ContadoresxAntiguedad]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
*/

ALTER PROCEDURE [InformesExcel].[ContadoresxAntiguedad]
	@p_params NVARCHAR(MAX),
	@p_errId_out INT OUTPUT, 
	@p_errMsg_out NVARCHAR(2048) OUTPUT
AS

	DECLARE @EDAD INT;
	DECLARE @ZONAD VARCHAR(4);
	DECLARE @ZONAH VARCHAR(4);
	DECLARE @ahora DATE = dbo.GetAcuamaDate();

	--**********
	--PARAMETROS: 
	--[1]Anios: Edad
	--**********
	SET NOCOUNT ON;   
	BEGIN TRY
	
	--********************
	--INICIO: 2 DataTables
	-- 1: Parametros del encabezado (Anios)
	-- 2: Datos
	--********************

	--DataTable[1]:  Parametros
	DECLARE @xml AS XML = @p_params;
	DECLARE @params TABLE (zonaD VARCHAR(4) NULL, [Edad Desde] INT NULL, zonaH VARCHAR(4) NULL, fInforme DATETIME);

	INSERT INTO @params
	OUTPUT INSERTED.*
	SELECT zonaD = M.Item.value('zonaD[1]', 'VARCHAR(4)') 
		 , [Edad Desde] = M.Item.value('valor[1]', 'INT') 
		 , zonaH = M.Item.value('zonaH[1]', 'VARCHAR(4)')
		 , fInforme     = dbo.GetAcuamaDate()		  			   
	FROM @xml.nodes('NodoXML/LI')AS M(Item);

	--********************
	--DataTable[2]:  Nombre de Grupos 
	SELECT * 
	FROM (VALUES('Contadores por antiguedad')) 
	AS DataTables(Grupo)


	--********************
	--DataTable[2]:  Datos
	
	SELECT @EDAD = ISNULL(P.[Edad Desde] , 0)
		 , @ZONAD = ISNULL(P.zonaD, '')
		 , @ZONAH = ISNULL(P.zonaH, '')
	FROM @params AS P;
	
	--**************************************************************************************
	--SYR-540030_Error datos informe Edad Parque Contadores
	--Nueva versión del informe: Simplificamos el informe haciendo uso de las vistas que ya tenemos
	--Cualquier duda consultar la version anterior en el repo o ContadoresxAntiguedad_old

	SELECT [Zona] = CONCAT(CHAR(9), C.[ctrZonCod])
	, [Contrato] = C.ctrCod
	, [Uso] = U.[usodes]
	, [Dirección Suministro] = I.[inmDireccion]
	--SYR-509403: Numero de serie del contador
	, [Contador] =  CASE  --Cuando el numero de serie es solo digitos y tiene mas de 11 el csv lo muestra en notación cientifica
				    WHEN (ISNUMERIC(CC.conNumSerie)=1 AND LEN(CC.conNumSerie)>=11)
					THEN CONCAT('"#',  CC.conNumSerie, '"')
					--Cuando es solo digitos lo metemos entre comillas para que no quite los ceros a la izquierda
					WHEN (ISNUMERIC(CC.conNumSerie)=1) 
					THEN CONCAT('"',  CC.conNumSerie, '"')
					--Cuando el numero de serie es formato fecha le ponemos el prefijo de # para que lo muestre con texto el csv
					WHEN (ISDATE(CC.conNumSerie)=1)
					THEN CONCAT('"#',  CC.conNumSerie, '"')
					--El resto de los casos lo mostramos tal cual viene
					ELSE CC.conNumSerie END
	, [Diametro] = CC.[conDiametro]
	, [F.Instalación] = FORMAT(CC.[I.ctcFec], 'dd/MM/yyyy')
	, [Marca] = M.[mcndes]
	, [Emplazamiento] = E.[emcdes]
	, [Edad] = DATEDIFF(YEAR, CC.[I.ctcFec], @ahora) -- [Edad_N]: Años desde la última instalación 
	, [Ruta1] = IIF(ISNUMERIC(CX.ctrRuta1)=1, CONCAT('',  CX.ctrRuta1, '.'), CX.ctrRuta1)
	, [Ruta2] = IIF(ISNUMERIC(CX.ctrRuta2)=1, CONCAT('',  CX.ctrRuta2, '.'), CX.ctrRuta2)
	, [Ruta3] = IIF(ISNUMERIC(CX.ctrRuta3)=1, CONCAT('',  CX.ctrRuta3, '.'), CX.ctrRuta3)
	, [Ruta4] = IIF(ISNUMERIC(CX.ctrRuta4)=1, CONCAT('',  CX.ctrRuta4, '.'), CX.ctrRuta4)
	, [Ruta5] = IIF(ISNUMERIC(CX.ctrRuta5)=1, CONCAT('',  CX.ctrRuta5, '.'), CX.ctrRuta5)
	, [Ruta6] = IIF(ISNUMERIC(CX.ctrRuta6)=1, CONCAT('',  CX.ctrRuta6, '.'), CX.ctrRuta6)
	, [RUTA] = CONCAT(RIGHT(REPLICATE('0',10) + ISNULL(CX.ctrRuta1,''), 10), '.',
								 RIGHT(REPLICATE('0',10) + ISNULL(CX.ctrRuta2,''), 10), '.',
								 RIGHT(REPLICATE('0',10) + ISNULL(CX.ctrRuta3,''), 10), '.',
								 RIGHT(REPLICATE('0',10) + ISNULL(CX.ctrRuta4,''), 10), '.',
								 RIGHT(REPLICATE('0',10) + ISNULL(CX.ctrRuta5,''), 10), '.',
								 RIGHT(REPLICATE('0',10) + ISNULL(CX.ctrRuta6,''), 10))
	INTO #RESULT
	FROM dbo.vContratosUltimaVersion AS C
	LEFT JOIN  dbo.vCambiosContador AS CC
	ON CC.ctrCod = C.ctrCod
	LEFT JOIN dbo.contratos AS CX
	ON  CX.ctrcod = C.ctrCod
	AND CX.ctrversion = C.ctrVersion
	LEFT JOIN dbo.Usos AS U
	ON U.usoCod = CX.ctrUsoCod
	LEFT JOIN dbo.inmuebles AS I
	ON I.inmCod = C.ctrInmCod
	LEFT JOIN dbo.emplaza AS E
	ON E.emccod = C.ctremplaza
	LEFT JOIN dbo.contador AS CO
	ON CO.conID = CC.conId
	LEFT JOIN dbo.marCon AS M
	ON M.mcncod = CO.conMcnCod
	WHERE CC.esUltimaInstalacion=1 AND CC.opRetirada IS NULL
	AND (LEN(@ZONAD)=0 OR  C.[ctrZonCod] >= @ZONAD)
	AND (LEN(@ZONAH)=0 OR  C.[ctrZonCod] <= @ZONAH);


	SELECT Zona, Contrato, Uso, [Dirección Suministro]
		 , Contador, Diametro, [F.Instalación], Marca, Emplazamiento
		 , Edad
		 , Ruta1, Ruta2, Ruta3, Ruta4, Ruta5, Ruta6
	FROM #RESULT
	WHERE Edad>=@EDAD
	ORDER BY RUTA;
	
	END TRY

	BEGIN CATCH
		SELECT  @p_errId_out = ERROR_NUMBER()
			 ,  @p_errMsg_out= ERROR_MESSAGE();
	END CATCH

	--********************
	--Borrar las tablas temporales
	IF OBJECT_ID('tempdb.dbo.#RESULT', 'U') IS NOT NULL  
	DROP TABLE dbo.#RESULT;

GO


