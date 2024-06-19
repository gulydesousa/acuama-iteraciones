/*
DECLARE @fechaFacturaD AS DATETIME = '20230201',
@fechaFacturaH AS DATETIME = '20231231',
@fechaLiquidacionD AS DATETIME = NULL,
@fechaLiquidacionH AS DATETIME = NULL,
@periodoD AS VARCHAR(6) = NULL,
@periodoH AS VARCHAR(6) = NULL,
@zonaD AS VARCHAR(4) = NULL,
@zonaH AS VARCHAR(4) = NULL
, @ctrcod AS INT = 415

EXEC dbo.Liquidaciones_Contratos_AVG @fechaFacturaD, @fechaFacturaH
, @fechaLiquidacionD, @fechaLiquidacionH
, @periodoD, @periodoH
, @zonaD, @zonaH
, @ctrcod;

SELECT ctrcod, ctrversion, ctrTitDir FROM contratos WHERE ctrcod=@ctrcod 

EXEC Liquidaciones_RegistrosContratos_AVG_old @fechaFacturaD, @fechaFacturaH
, @fechaLiquidacionD, @fechaLiquidacionH
, @periodoD, @periodoH
, @zonaD, @zonaH
, @ctrcod;

EXEC Liquidaciones_RegistrosContratos_AVG_nuevo @fechaFacturaD, @fechaFacturaH
, @fechaLiquidacionD, @fechaLiquidacionH
, @periodoD, @periodoH
, @zonaD, @zonaH
, @ctrcod;
*/

ALTER PROCEDURE dbo.Liquidaciones_Contratos_AVG
@fechaFacturaD AS DATETIME = NULL,
@fechaFacturaH AS DATETIME = NULL,
@fechaLiquidacionD AS DATETIME = NULL,
@fechaLiquidacionH AS DATETIME = NULL,
@periodoD AS VARCHAR(6) = NULL,
@periodoH AS VARCHAR(6) = NULL,
@zonaD AS VARCHAR(4) = NULL,
@zonaH AS VARCHAR(4) = NULL,
@ctrcod AS INT  = NULL
AS
--****************************
--****************************
-- Version corregida a raíz del canon anual de 2023
-- Se parte de la version anterior: "Liquidaciones_RegistrosContratos_AVG"
-- Algunas facturas se quedaban por fuera del informe al cotejar con el reporte:
-- CR019_ListadoLiquidaciones.rdl
--****************************
--****************************


--*** VARIABLES FECHAS ***
--Convertimos a date e incrementamos un día al hasta
DECLARE @facFechaD DATE;
DECLARE @facFechaH DATE;

DECLARE @liqFechaD DATE;
DECLARE @liqFechaH DATE;

DECLARE @fechaPerD AS DATE;
DECLARE @fechaPerH AS DATE;

SET @fechaPerD = (SELECT TOP 1 przfPeriodoD FROM dbo.perzona AS P WHERE P.przcodper = @periodoD)
SET @fechaPerH = (SELECT TOP 1 przfPeriodoH FROM dbo.perzona AS P WHERE P.przcodper = @periodoH)

SELECT @facFechaD = IIF(@fechaFacturaD IS NOT NULL, @fechaFacturaD, NULL),
	   @facFechaH = IIF(@fechaFacturaH IS NOT NULL, DATEADD(DAY, 1, @fechaFacturaH), NULL),
	   @fechaPerH = IIF(@fechaPerH IS NOT NULL, DATEADD(DAY, 1, @fechaPerH), NULL),
	   @liqFechaD = IIF(@fechaLiquidacionD IS NOT NULL, @fechaLiquidacionD, NULL),
	   @liqFechaH = IIF(@fechaLiquidacionH IS NOT NULL, DATEADD(DAY, 1, @fechaLiquidacionH), NULL);

--*** D E B U G ****
--SELECT [@liqFechaD]=@liqFechaD, [@liqFechaH]= @liqFechaH, [@facFechaD]=@facFechaD, [@facFechaH]=@facFechaH;
--******************

--*** TARIFAS ****
--Nos ayudarán a distinguir cuando es 'Domestico' o 'No-Domestico'
DECLARE @TRF AS TABLE(svcCod INT, trfCod INT);
INSERT INTO @TRF(svcCod, trfCod)
VALUES (20, 101), (20, 401), (20, 501), (20, 601), (20, 701), (20, 1001), (20, 8501);

BEGIN TRY
	--*********************************************************
	--*********************************************************
	--[01]#FACLIN: Facturas con sus lineas de canon (19, 20, 60)
	SELECT F.faccod, F.facCtrCod, F.facPerCod, F.facVersion, F.facNumero
	, F.facFecha
	, F.facFechaRectif
	, F.facCtrVersion
	, [ctrTitDocIden] = UPPER(LTRIM(RTRIM(C.ctrTitDocIden)))
	, [facUso] = CAST(NULL AS VARCHAR(1))
	, [fclUso] = CASE FL.fclTrfSvCod WHEN 20 THEN IIF(T.trfCod IS NOT NULL, 'D', 'N') ELSE NULL END
	--[FacturaAnulada]=1 : Facturas que no tomaremos en cuenta para la liquidación
	, [FacturaAnulada] = CAST(0 AS BIT)
	, [Siguiente_facVersion] = F1.facVersion
	, [Anterior_facVersion] = F0.facVersion
	, [Anterior_ServiciosCanon] = CAST(NULL AS TINYINT)
	, FL.fclTrfSvCod, FL.fclTrfCod
	--Ultima version de cada factura FAC_RN=1
	, FAC_RN = DENSE_RANK() OVER (PARTITION BY F.faccod, F.facCtrCod, F.facPerCod ORDER BY F.facVersion DESC)
	--Ordenamos las lineas por factura, si tiene el servicio 19: Canon Fijo debería ser el primero FL_RN=1
	, FL_RN  = ROW_NUMBER() OVER (PARTITION BY F.faccod, F.facCtrCod, F.facPerCod, F.facVersion ORDER BY FL.fclTrfSvCod DESC, FL.fclNumLinea DESC)
	--RN=1 para obtener la ultima linea de factura de cada contrato
	, RN = ROW_NUMBER() OVER (PARTITION BY F.facCtrCod ORDER BY  F.facPerCod DESC, F.faccod DESC, F.facVersion DESC, FL.fclTrfSvCod DESC, FL.fclNumLinea)
	--RN_CTR=1 para obtener la ultima linea de factura de cada contrato con version
	, RN_CTR = ROW_NUMBER() OVER (PARTITION BY F.facCtrCod, F.facCtrVersion ORDER BY  F.facPerCod DESC, F.faccod DESC, F.facVersion DESC, FL.fclTrfSvCod DESC, FL.fclNumLinea)
	INTO #FACLIN
	FROM dbo.facturas AS F 
	INNER JOIN dbo.contratos AS C
	ON  F.facCtrCod = C.ctrcod
	AND F.facCtrVersion = C.ctrversion
	AND (@ctrcod IS NULL OR C.ctrcod=@ctrcod)
	--Solo facturas con las lineas del canon
	INNER JOIN dbo.faclin AS FL 
	ON  FL.fclFacCtrCod = F.facCtrCod 
	AND FL.fclFacPerCod= F.facPerCod 
	AND FL.fclFacCod= F.facCod 
	AND FL.fclFacVersion= F.facVersion
	--19: CANON FIJO
	--20: CANON VARIABLE
	AND FL.fclTrfSvCod IN (19, 20)	
	--Tarifas
	LEFT JOIN @TRF AS T
	ON T.svcCod = FL.fclTrfSvCod
	AND T.trfCod = FL.fclTrfCod
	--Factura anterior
	LEFT JOIN dbo.facturas AS F0 
	ON F0.facCod = F.facCod
	AND F0.facPerCod = F.facPerCod
	AND F0.facCtrCod = F.facCtrCod
	AND F0.facFechaRectif = F.facFecha
	AND F0.facNumeroRectif = F.facNumero
	--Factura siguiente
	LEFT JOIN dbo.facturas AS F1 
	ON F1.facCod = F.facCod
	AND F1.facPerCod = F.facPerCod
	AND F1.facCtrCod = F.facCtrCod
	AND F1.facFecha = F.facFechaRectif
	AND F1.facNumero = F.facNumeroRectif
	WHERE F.facFecha IS NOT NULL --Excluir prefacturas
	--*** Contratos ***
	AND (@zonaD IS NULL OR C.ctrZonCod >= @zonaD) 
	AND (@zonaH IS NULL OR C.ctrZonCod <= @zonaH)
	--*** Liquidadas ****
	AND (FL.fclFecLiqImpuesto IS NOT NULL AND fclUsrLiqImpuesto IS NOT NULL) 
	--Fecha de liquidación
	AND (@liqFechaD IS NULL OR FL.fclFecLiqImpuesto >= @liqFechaD) 
	AND (@liqFechaH IS NULL OR FL.fclFecLiqImpuesto < @liqFechaH) 
	--*** Periodo ****
	--Fecha del periodo
	AND (@fechaPerD IS NULL OR F.facFecha >= @fechaPerD) 
	AND (@fechaPerH IS NULL OR F.facFecha < @fechaPerH) 
	--Codigo del periodo
	AND (((@periodoD IS NULL OR F.facPerCod >= @periodoD) AND (@periodoH IS NULL OR F.facPerCod <= @periodoH)) --Dentro del periodo
		OR (F.facPerCod LIKE '0%')) --Periodo de consumo
	--*** Facturas ***	 
	--Fecha de la factura
	AND (@facFechaD IS NULL OR F.facFecha >= @facFechaD) 
	AND (@facFechaH IS NULL OR F.facFecha <  @facFechaH);
	
	--*********************************************************
	--[02]#FACLIN.FacturaAnulada: Marcamos aquellas facturas que no tienen una rectificativa activa
	--En el caso que una factura no tenga una rectificativa que la reemplace la omitiremos del listado
	--Es como si no hubiese existido
	WITH ANULADAS AS(
	SELECT facCod, facPerCod, facCtrCod, facVersion 
	FROM #FACLIN AS F
	WHERE FL_RN = 1 --Ultima version de la factura
	AND F.facFechaRectif IS NOT NULL -- Está rectificada
	--No existe una rectificada que la sustituya
	AND F.Siguiente_facVersion IS NULL)

	UPDATE FL SET FacturaAnulada=1
	FROM #FACLIN AS FL
	INNER JOIN ANULADAS AS A
	ON  A.facCod = FL.facCod
	AND A.facCtrCod = FL.facCtrCod
	AND A.facPerCod = FL.facPerCod;
	
	--*********************************************************
	--[03]#FACLIN.[Anterior_ServiciosCanon] 
	--En las rectificativas, comprobamos si la factura anterior tenía también los servicios del canon
	WITH NUMCANON AS(
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion
	--Cuantos servicios diferentes hay asociados a la factura
	--Se espera que siempre sean 2
	, countSvc = COUNT(DISTINCT FL.fclNumLinea) 
	FROM #FACLIN AS F
	INNER JOIN dbo.faclin AS FL
	ON F.facCod = FL.fclFacCod
	AND F.facPerCod = FL.fclFacPerCod
	AND F.facCtrCod = FL.fclFacCtrCod
	AND F.Anterior_facVersion = FL.fclFacVersion
	--19: CANON FIJO
	--20: CANON VARIABLE
	AND FL.fclTrfSvCod IN (19, 20)	
	WHERE F.FL_RN=1 --Consultamos por cada version de factura
	GROUP BY F.facCod, F.facPerCod, F.facCtrCod, F.facVersion
	HAVING COUNT(DISTINCT FL.fclNumLinea)>0)

	UPDATE FL SET FL.Anterior_ServiciosCanon = NC.countSvc
	FROM #FACLIN AS FL
	INNER JOIN NUMCANON AS NC
	ON FL.facCod = NC.facCod
	AND FL.facCtrCod = NC.facCtrCod
	AND FL.facPerCod = NC.facPerCod
	AND FL.facVersion = NC.facVersion;

	--*********************************************************
	--[04]#FACLIN.[facUso]
	--El uso de la factura lo determina la tarifa que tiene asociada el servicio 20
	--En caso de que haya distintas tarifas, domésticas y no-domésticas:
	--Se prioriza (N)o-(D)oméstico -Por orden alfabetico-
	WITH USO AS(
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion
		 , facUso = MAX(fclUso) 
	FROM #FACLIN AS F
	GROUP BY F.facCod, F.facPerCod, F.facCtrCod, F.facVersion)

	UPDATE FL SET facUso = U.facUso 
	FROM #FACLIN AS FL
	INNER JOIN USO AS U
	ON FL.facCod = U.facCod
	AND FL.facPerCod = U.facPerCod
	AND FL.facCtrCod = U.facCtrCod
	AND FL.facVersion = U.facVersion;
	   
	   
	--***  D E B U G  ***
	--SELECT * FROM #FACLIN;
	--*********************

	--*********************************************************
	--*********************************************************
	--[10]#FACS: Ya tenemos todos los datos de las lineas de la factura
	--Vamos a hora a centrarnos en la informacion que necesitamos de cada factura
	--Una linea por factura
	SELECT facCod, facCtrCod, facPerCod, facVersion, facNumero
	, F.facFecha, F.facFechaRectif
	, F.facCtrVersion, F.ctrTitDocIden
	, F.facUso
	, F.Siguiente_facVersion
	, F.Anterior_facVersion, F.Anterior_ServiciosCanon 

	--NumFacActivas: Facturas sin fecha de rectificacion por version de contrato
	, NumFacActivas = SUM(IIF(facFechaRectif IS NULL, 1, 0)) OVER (PARTITION BY F.facCtrCod, F.facCtrVersion)

	--NumFacRectificativas: Facturas que rectifican a una factura que tenía el canon
	, NumFacRectificativas = SUM(Anterior_ServiciosCanon) OVER (PARTITION BY F.facCtrCod, F.facCtrVersion)

	--RN_CTR=1 para obtener la ultima factura de cada contrato con version
	, RN_CTR = ROW_NUMBER() OVER (PARTITION BY F.facCtrCod, F.facCtrVersion ORDER BY  F.facPerCod DESC, F.faccod DESC, F.facVersion DESC)
	--RN=1 para obtener la ultima factura de cada contrato
	, RN = ROW_NUMBER() OVER (PARTITION BY F.facCtrCod ORDER BY  F.facPerCod DESC, F.faccod DESC, F.facVersion DESC)

	INTO #FACS
	FROM #FACLIN AS F
	WHERE F.FacturaAnulada = 0 
	AND F.FL_RN=1; --La primera linea de la factura y evitar duplicados por factura

	--***  D E B U G  ***
	--SELECT * FROM #FACS;
	--SELECT * FROM #FACLIN;
	--*********************
	
	--*********************************************************
	--*********************************************************
	--[20]#CTR: Ya tenemos todos los datos de las facturas
	--Vamos a hora a sacar un registro por versión de contrato
	SELECT facCtrCod, facCtrVersion, ctrTitDocIden
	, F.facUso --El uso de la ultima factura asociada a esta version de contrato
	--*****************************************************************************
	--*** Lead (anterior) y Lag (siguiente)
	--*** Para saber si el cambio de version es por cambio de titular ***
	--Si estamos en la version 1 y la version siguiente en esta selección es la "x"
	--[TitularLead] es el titular de la version "x"
	, [TitularLead] = LEAD(F.ctrTitDocIden) OVER (PARTITION BY F.facCtrCod ORDER BY F.facCtrVersion ASC)
	
	--Si estamos en la version x y la version anterior en esta selección es la "1"
	--[TitularLag] es el titular de la version "1"
	, [TitularLag] = LAG(F.ctrTitDocIden) OVER (PARTITION BY F.facCtrCod ORDER BY F.facCtrVersion ASC)
	--*****************************************************************************
	--Numero de versiones que tenemos para cada contrato
	, CN=COUNT(facCtrVersion) OVER (PARTITION BY facCtrCod)
	, RN=ROW_NUMBER() OVER (ORDER BY facCtrCod, facCtrVersion ASC) 
	INTO #CTR 
	FROM #FACS AS F
	WHERE RN_CTR=1
	AND (ISNULL(NumFacActivas, 0)>0 OR ISNULL(NumFacRectificativas, 0)>0);

	--*********************************************************
	--*********************************************************
	--[30]#CTR_TITULAR: Para cada combinación: (contrato, titular) 
	--Buscamos las ultima versión RN=1
	SELECT C.ctrcod
	, C.ctrTitDocIden
	, C.ctrTitTipDoc
	, C.ctrversion
	, ctrTitNom = SUBSTRING(C.ctrTitNom,1,125)
	, ctrTitDir = C.ctrTitDir
	, C.ctrfecreg
	, C.ctrfecanu
	, C.ctrComunitario
	, C.ctrValorc1
	, C.ctrinmcod
	, flagBaja = IIF(C.ctrbaja IS NOT NULL AND C.ctrbaja=1 AND C.ctrfecanu>=@facFechaD AND C.ctrfecanu<@facFechaH, C.ctrbaja , 0)
	--RN=1: Ultima versión de la combinacion contrato, titular: De donde tomaremos los datos 
	, RN = ROW_NUMBER() OVER (PARTITION BY CC.facCtrCod, CC.ctrTitDocIden ORDER BY CC.facCtrVersion DESC) 
	INTO #CTR_TITULAR
	FROM #CTR AS CC
	INNER JOIN dbo.contratos AS C
	ON C.ctrcod= CC.facCtrCod
	AND C.ctrversion = CC.facCtrVersion;
	


	--*********************************************************
	--[99]SALIDA
	--*********************************************************
	SELECT C.ctrcod
	, C.ctrversion
	--Los datos los traemos de la ultima vesion por combinación CT (Contrato, Titular)
	, CT.ctrTitDocIden
	, [tipo]= 'C'
	, [tipoIdent] = CASE WHEN CT.ctrTitTipDoc IN ('0','1') THEN 'F'
						WHEN CT.ctrTitTipDoc IN ('2','4') THEN 'E'
						ELSE 'O' END
	, [nomTit] = CT.ctrTitNom
	, [titDir] = IIF(CT.ctrTitDir <> I.inmDireccion, SUBSTRING(CT.ctrTitDir, 1 ,250), NULL)
	, [titPrv] = '11'
	, [titPob] = '0337'
	, [contador] = IIF(CT.ctrComunitario IS NULL AND CT.ctrValorc1 > 1,  'C' , 'I')
	, [uso] = CC.facUso
	, [usuarios] = IIF(CT.ctrComunitario IS NULL AND CT.ctrValorc1 > 1, CT.ctrValorc1, NULL)
	, refCatastral = IIF(LEN(TRIM(I.inmrefcatastral)) = 20, TRIM(I.inmrefcatastral), NULL)	
	, dirAbastecida = SUBSTRING(I.inmDireccion, 1, 250)
	, periodicidad = 3
	, C.ctrfecreg
	, C.ctrfecanu
	
	, [ctrbaja] = CT.flagBaja
	, [indAlta] = CASE WHEN C.ctrVersion=1 AND C.ctrfecreg>=@facFechaD AND C.ctrfecreg<@facFechaH THEN 'C'
					   WHEN CC.ctrTitDocIden <> CC.TitularLag	THEN 'T'
					   ELSE NULL END

	, [indBaja] = CASE WHEN CT.flagBaja=1 AND C.ctrfecanu>=@facFechaD AND C.ctrfecanu<@facFechaH THEN 'C'
					   WHEN CC.ctrTitDocIden <> CC.TitularLead THEN 'T'
					   ELSE NULL END	
	, CC.RN
	FROM #CTR AS CC
	LEFT JOIN #CTR_TITULAR AS CT
	ON  CT.ctrcod = CC.facCtrCod
	AND CT.ctrTitDocIden = CC.ctrTitDocIden
	AND CT.RN=1
	LEFT JOIN dbo.contratos AS C
	ON C.ctrcod = CC.facCtrCod
	AND C.ctrversion = CC.facCtrVersion
	LEFT JOIN dbo.inmuebles AS I
	ON I.inmcod = CT.ctrinmcod
	ORDER BY CC.facCtrCod, CC.facCtrVersion;
	
	--***  D E B U G  ***
	IF (@ctrcod IS NOT NULL)
	BEGIN
		
		SELECT '#CTR',  * FROM #CTR;
		SELECT '#CTR_TITULAR',  * FROM #CTR_TITULAR;
		SELECT '#FACS', * FROM #FACS;
		SELECT '#FACLIN', * FROM #FACLIN;	
	END
	--*********************
END TRY
BEGIN CATCH
END CATCH

DROP TABLE IF EXISTS #FACLIN;
DROP TABLE IF EXISTS #FACS;
DROP TABLE IF EXISTS #CTR;
DROP TABLE IF EXISTS #CTR_TITULAR;

GO