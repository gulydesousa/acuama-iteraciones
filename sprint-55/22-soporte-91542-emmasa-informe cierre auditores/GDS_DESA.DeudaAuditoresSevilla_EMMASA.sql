DECLARE @NIF VARCHAR(10) = '45708324X';

DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);
SET @p_params= '<NodoXML><LI><FecDesde>20140601</FecDesde><FecHasta>20240529</FecHasta></LI></NodoXML>';
/*
EXEC [dbo].[Excel_ExcelConsultas.DeudaAuditoresSevilla_EMMASA]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
SELECT @p_errMsg_out


CREATE PROCEDURE [dbo].[Excel_ExcelConsultas.DeudaAuditoresSevilla_EMMASA]
	@p_params NVARCHAR(MAX),
	@p_errId_out INT OUTPUT, 
	@p_errMsg_out NVARCHAR(2048) OUTPUT

AS
*/
	--**********
	--PARAMETROS: 
	--[1]fecFhacDesde: fecha dede
	--[2]fechFacHasta: fecha hasta
	--**********

	SET NOCOUNT ON;   
	--BEGIN TRY
	
	--********************
	--INICIO: 2 DataTables
	-- 1: Parametros del encabezado (fecFhacDesde, fechFacHasta)
	-- 2: Datos
	--********************

	--DataTable[1]:  Parametros y variables
	DECLARE @FechaInicioExplotacion DATE;
	SELECT @FechaInicioExplotacion = pgsvalor 
	FROM parametros WHERE pgsclave = 'FECHA_INICIO_EXPLOTACION';

	DECLARE @ahora DATE = dbo.GetAcuamaDate();
	SET @ahora =  IIF(@FechaInicioExplotacion>@ahora, @FechaInicioExplotacion, @ahora);
	
	DECLARE @xml AS XML = @p_params;
	DECLARE @params TABLE (fechaD DATE NULL, fInforme DATETIME, fechaH DATE NULL);

	INSERT INTO @params
	SELECT  fechaD = CASE WHEN M.Item.value('FecDesde[1]', 'DATE') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecDesde[1]', 'DATE') END
		  , fInforme     = dbo.GetAcuamaDate()
		  , fechaH = CASE WHEN M.Item.value('FecHasta[1]', 'DATE') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecHasta[1]', 'DATE') END
	FROM @xml.nodes('NodoXML/LI')AS M(Item);

	UPDATE @params 
	SET fechaH = DATEADD(DAY, 1, fechaH)
	OUTPUT DELETED.fechaD AS FecDesde, DELETED.fInforme, DELETED.fechaH AS FecHasta;

	--********************
	--VALIDAR PARAMETROS
	--Fechas obligatorias
	IF EXISTS(SELECT 1 FROM @params WHERE fechaD IS NULL OR fechaH IS NULL)
		THROW 50001 , 'La fecha ''desde'' y ''hasta'' son requeridos.', 1;
	IF EXISTS(SELECT 1 FROM @params WHERE fechaD>fechaH)
		THROW 50002 , 'La fecha ''hasta'' debe ser posterior a la fecha ''desde''.', 1;

	--********************
	--CM - Compensación.
	DECLARE @COMPENSACION AS INT;
	SELECT @COMPENSACION=mpccod 
	FROM dbo.medpc AS M WHERE M.mpcdes = 'Compensación';

	--DE - Devuelto.
	DECLARE @DOMICILIACION AS INT = 0;
	SELECT @DOMICILIACION=mpccod 
	FROM dbo.medpc AS M WHERE M.mpcdes = 'Domiciliación bancar';

	--[01]Entregas a cuenta: pendientes por cliente
	SELECT CTR.ctrTitDocIden, CTR.ctrTitCod
	, EntregasCta = SUM(CL.cblImporte)
	INTO #ECTR
	FROM dbo.cobros AS C
	INNER JOIN dbo.coblin AS CL 
	ON CL.cblPer = '999999'
	AND CL.cblPpag = C.cobPpag 
	AND CL.cblNum = C.cobNum 
	AND CL.cblScd = C.cobScd
	INNER JOIN dbo.vContratoUltVersion AS CTR 
	ON CTR.ctrcod = C.cobCtr
	--Cobros de entrega a cuenta creados entre las fechas
	INNER JOIN @params AS P 
	ON (P.fechaD IS NULL OR C.cobFec >= P.fechaD)  AND 
	(P.fechaH IS NULL OR C.cobFec < P.fechaH)
	GROUP BY CTR.ctrTitDocIden, CTR.ctrTitCod
	HAVING SUM(CL.cblImporte)<>0;
	
	--*** DEBUG ****
	SELECT * FROM #ECTR WHERE ctrTitDocIden=@NIF;

	--[02]Entregas a cuenta: pendientes por titular
	SELECT ctrTitDocIden
	, EntregasCta = SUM(EntregasCta)
	INTO #EC
	FROM #ECTR AS C
	GROUP BY ctrTitDocIden;

		
	--*** DEBUG ****
	SELECT * FROM #EC WHERE ctrTitDocIden=@NIF;


	--**************
	--[10]TOTAL FACTURAS: Sacamos las facturas que por fechas son las que conformarían el reporte
	-- #FACTOTALES
	DECLARE @sql NVARCHAR(MAX);
	
	SELECT T.ftfFacCod, T.ftfFacPerCod, T.ftfFacCtrCod, T.ftfFacVersion, T.ftfImporte
	INTO #FACTOTALES
	FROM _FACTOTALES AS T;
	--FROM dbo.fFacturas_TotalFacturado(NULL, NULL, NULL) AS T;

	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACTOTALES(ftfFacCod, ftfFacPerCod, ftfFacCtrCod, ftfFacVersion)';
	EXEC sp_executesql @sql;
	
	--**************
	--[11]FACTURAS: Sacamos las facturas que por fechas son las que conformarían el reporte
	-- #FACS: Filtramos las facturas que van para el informe
	SELECT F.facCod
	, F.facPerCod
	, F.facCtrCod
	, F.facVersion	
	, F.facCtrVersion
	, F.facNumero
	, F.facEstado
	, F.facNumeroAqua
	, C.ctrTitDocIden 
	--**********************
	, F.facFechaRectif
	, F.facNumeroRectif
	, F.facSerieRectif
	, F.facFechaVto
	, F.facFechaVtoOrig
	--**********************
	, facTotal = ISNULL(FT.ftfImporte, 0)
	, facImporteRectif =  CAST(NULL AS MONEY)
	--**********************
	, facRfsCodigo = CAST(NULL AS INT)
	, '' AS facEstadoEmmasa
	--Los Efectos Pendientes no van por versión de factura así que...
	--Para saber cual es la última version de la factura y asociar a ella los efectos pendientes
	--RN_FAC=1: Ultima vesión de la factura
	, RN_FAC = ROW_NUMBER() OVER (PARTITION BY F.facCod, F.facPerCod, F.facCtrCod ORDER BY F.facVersion DESC)
	--**********************
	INTO #FACS
	FROM dbo.facturas AS F
	LEFT JOIN #FACTOTALES AS FT
	ON  F.facCod = FT.ftfFacCod
	AND F.facPerCod = FT.ftfFacPerCod
	AND F.facCtrCod = FT.ftfFacCtrCod
	AND F.facVersion = FT.ftfFacVersion	
	INNER JOIN dbo.contratos AS C
	ON C.ctrcod = F.facCtrCod AND C.ctrversion = F.facCtrVersion
	--Facturas creadas dentro del rango de fechas
	INNER JOIN @params AS P
	ON  (P.fechaD IS NULL OR F.facFecha >= P.fechaD) 
	AND (P.fechaH IS NULL OR F.facFecha < P.fechaH)

	WHERE F.facNumero IS NOT NULL	--Se excluyen las prefacturas
	AND F.facEstado NOT IN (4,5)	--Se excluyen las (4) AGRUPADAS NI (5) TRASPASADAS-TR-. No es deuda 	
	AND ctrTitDocIden=@NIF;

	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACS(facCod, facPerCod, facCtrCod, facVersion)';
	EXEC sp_executesql @sql;	
	
	--*** DEBUG ***
	--SELECT * FROM #FACS WHERE ctrTitDocIden=@NIF;
		
	--**********************
	--[12]RECTIFICATIVAS: Para saber las "Anuladas", tenemos que calcular el importe de las facturas rectificativas
	-- #FACS.facImporteRectif: Importe de la factura rectificativa
	UPDATE FF SET FF.facImporteRectif = T.ftfImporte
	FROM #FACS AS FF
	INNER JOIN dbo.facturas AS R
	ON  FF.facFechaRectif IS NOT NULL
	AND FF.facCod = R.facCod
	AND FF.facPerCod = R.facPerCod
	AND FF.facCtrCod = R.facCtrCod  
	AND FF.facFechaRectif = R.facFecha 
	AND FF.facNumeroRectif = R.facNumero 
	AND FF.facSerieRectif = R.facSerCod
	INNER JOIN #FACTOTALES AS T
	ON T.ftfFacCod = R.facCod
	AND T.ftfFacPerCod = R.facPerCod
	AND T.ftfFacCtrCod = R.facCtrCod
	AND T.ftfFacVersion = T.ftfFacVersion;
	
	
	--**************
	--[13]Para saber las que están en estado "Rechazada". Lo setearemos con un UPDATE 
	-- #FACS.facRfsCodigo: Rechazadas
	-- #FACS.facEstadoEmmasa: Estados de Emmasa
	WITH RECHAZADAS AS (
	SELECT F.facCod
	, F.facPerCod
	, F.facCtrCod
	, F.facVersion 
	, MAX(R.rfsCodigo) AS rfsCodigo
	FROM #FACS AS F
	INNER JOIN dbo.refacturacionesLineas AS RL
	ON  RL.rflFacCod = F.facCod
	AND RL.rflFacPerCod = F.facPerCod
	AND RL.rflFacCtrCod = F.facCtrCod
	AND RL.rflFacVersion = F.facVersion
	INNER JOIN dbo.refacturaciones AS R
	ON  R.rfsCodigo = RL.rflFacCod
	AND R.rfsFechaGeneracion IS NULL
	GROUP BY F.facCod, F.facPerCod, F.facCtrCod, F.facVersion)

	--ID rechazada
	UPDATE F
	SET F.facRfsCodigo  = FT.rfsCodigo,
		F.facEstadoEmmasa = CASE
							--V	Retenida pendiente de Validación / NO APLICA	
							--A	Retenida pendiente de Aprobación / NO APLICA	
							--E: Rechazada pendiente de Expediente / Facturas incluidas en una propuesta de refacturación
							WHEN FT.rfsCodigo IS NOT NULL THEN 'E'
							--N: Anulada/Facturas anuladas
							WHEN F.facNumeroRectif IS NOT NULL AND F.facImporteRectif = 0 THEN  'N'
							--R	Rechazada pendiente de Revisión	
							WHEN F.facNumeroRectif IS NOT NULL AND F.facImporteRectif <> 0 THEN  'R'
							--B: Albarán/Facturas con estado 7
							WHEN (F.facEstado IS NOT NULL AND F.facEstado = 7) THEN 'B' 	
							--G: Generada/ FACTURA REAL (prefactura?)
							WHEN F.facNumero IS NULL THEN 'G'
							--F: Facturada/Facturas / FACTURA REAL
							WHEN (F.facNumero IS NOT NULL) THEN 'F' 
							ELSE '' END 
	FROM #FACS AS F
	LEFT JOIN RECHAZADAS AS FT
	ON  F.facCod = FT.facCod
	AND F.facPerCod = FT.facPerCod
	AND F.facCtrCod = FT.facCtrCod
	AND F.facVersion = FT.facVersion;

	--**** DEBUG *****
	--SELECT * FROM #FACS;

	--**************
	--[14]Borramos de la tabla #FACS las que no nos interesan, por su estado, para sacar el informe
	-- #FACS: Excluimos facturas que no se toman en cuenta para el informe
	DELETE FROM F
	FROM #FACS AS F
	WHERE F.facTotal IS NULL 
	OR F.facTotal = 0
	OR F.facNumero IS NULL	 --PREFACTURAS
	OR F.facEstadoEmmasa='N' --ANULADAS
	OR F.facFechaRectif IS NOT NULL; --Se omiten en consecuencia las Anuladas-AN-


	--**** DEBUG *****
	SELECT * FROM #FACS WHERE ctrTitDocIden=@NIF ORDER BY facPerCod;
	
	--**************
	--[20]Recuperamos los Efectos pendientes de las facturas:
	--Efectos Pendientes
	SELECT F.facCod
	, F.facCtrCod
	, F.facPerCod
	, F.facVersion
	, F.ctrTitDocIden
	, EP.efePdteCod
	, EP.efePdteScd
	, EP.efePdteImporte
	, EP.efePdteFecVencimiento
	--Totalización de los efectos pendientes por factura
	, TOTAL_EPS = SUM(EP.efePdteImporte) OVER(PARTITION BY F.facCod, F.facCtrCod, F.facPerCod)
	--CN_EP = Efectos pendientes por factura
	, CN_EP = COUNT(EP.efePdteCod) OVER(PARTITION BY F.facCod, F.facCtrCod, F.facPerCod)
	--RN_EP=1 : Ultimo efecto pendiente por factura
	, RN_EP = ROW_NUMBER() OVER(PARTITION BY F.facCod, F.facCtrCod, F.facPerCod ORDER BY EP.efePdteCod DESC)
	INTO #EPS
	FROM #FACS AS F
	INNER JOIN dbo.efectosPendientes AS EP
	ON EP.efePdteFacCod = F.facCod
	AND EP.efePdtePerCod = F.facPerCod
	AND EP.efePdteCtrCod = F.facCtrCod
	AND EP.efePdteFecRechazado IS NULL
	AND F.RN_FAC=1;

	--**** DEBUG *****
	SELECT * FROM #EPS;

	
	--**************
	--[30]Totalizamos los cobros por FACTURA (sin version)
	--Para calcular el estado del pago necesitamos detalles del total de los cobros asi como el último cobro 
	-- #COBROS
	SELECT F.facCod 
	, F.facPerCod
	, F.facCtrCod
	, F.facVersion
	, CB.cobScd
	, CB.cobPpag
	, CB.cobNum
	, CB.cobMpc
	, CB.cobFec
	, CB.cobOrigen
	, CBL.cblLin
	, CBL.cblImporte
	--CN_COB: Número de cobros de compensación por factura
	, CN_COB_COMP = SUM(IIF(CB.cobMpc=@COMPENSACION, 1, 0)) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod)
	--CN_COB: Número de cobros por factura
	, CN_COB = COUNT(CB.cobNum) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod)
	--RN_COB=1: Cobro mas reciente
	, RN_COB = ROW_NUMBER() OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod ORDER BY CB.cobFec DESC, CB.cobfecReg DESC)
	--TOTAL_COB: Total cobrado por factura
	, TOTAL_COB = SUM(CBL.cblImporte) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod)
	-- Efecto pendiente asociado si es el caso
	, CLEP.clefePdteFacCod
	, CLEP.clefePdteCtrCod
	, CLEP.clefePdtePerCod
	, CLEP.cleCblScd
	, CLEP.clefePdteCod
	--TOTAL_COB: Total cobrado por efecto pendiente
	, TOTAL_EPCOB = SUM(CBL.cblImporte) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod, CLEP.clefePdteCod)
	--RN_EPCOB=1: Cobro mas reciente por efecto pendiente
	, RN_EPCOB = ROW_NUMBER() OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod, CLEP.clefePdteCod ORDER BY CB.cobFec DESC, CB.cobfecReg DESC)
	--CN_EPCOB: Número de cobros por efectos pendientes
	, CN_EPCOB = COUNT(CB.cobNum) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod, CLEP.clefePdteCod)
	INTO #COBS
	FROM  #FACS AS F	
	INNER JOIN dbo.cobros AS CB
	ON F.RN_FAC = 1 --RN_FAC=1: Ultima vesión de la factura
	AND CB.cobCtr = F.facCtrCod	
	INNER JOIN dbo.coblin AS CBL
	ON  CB.cobScd = CBL.cblScd
	AND CB.cobPpag = CBL.cblPpag
	AND CB.cobNum = CBL.cblNum
	AND CBL.cblFacCod = F.facCod
	AND CBL.cblPer = F.facPerCod
	LEFT JOIN dbo.cobLinEfectosPendientes AS CLEP
	ON  CLEP.cleCblScd = CBL.cblScd
	AND CLEP.cleCblPpag = CBL.cblPpag
	AND CLEP.cleCblNum = CBL.cblNum
	AND CLEP.cleCblLin = CBL.cblLin;
	
	--**** DEBUG *****
	SELECT * FROM #COBS ORDER BY facCtrCod, facPerCod, RN_COB;
	
	
	--[41] Estado: Facturas
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumeroAqua
	, F.facTotal
	, F.ctrTitDocIden
	, EPS.TOTAL_EPS --Totalizacion de los efectos pendientes
	, C.TOTAL_COB	--Total cobrado por factura
	, C.CN_COB		--Numero de cobros
	, C.CN_COB_COMP --Numero de cobros por compensación
	, EPS.CN_EP		--Numero de efectos pendientes por factura
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, [cobEstado] = CASE 
	--FR: Fraccionado/ una factura con efectos pendientes
	WHEN  EPS.CN_EP IS NOT NULL AND EPS.CN_EP>0 THEN 'FR'
	--PD: Si el importe cobrado supera el importe total de la factura (Pendiente devolución)
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) > F.facTotal  THEN 'PD' 
	--CM: Compensando / Facturas cobradas por el punto de pago compensación (todos los cobros son por compensación)
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) = F.facTotal AND C.CN_COB IS NOT NULL AND C.CN_COB > 0 AND C.CN_COB = C.CN_COB_COMP THEN 'CM' 
	--CD: Cobro detenido/Facturas con facEstado = 6
	WHEN (F.facEstado = 6) THEN 'CD'
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) = F.facTotal THEN 'CO'
	--VE: Vencido/ Facturas no cobradas y la fecha de vencimiento se ha cumplido. Prevalece sobre el aplazado
	WHEN ISNULL(F.facFechaVto, F.facFechaVtoOrig) <  @ahora THEN 'VE'
	--DE: Devuelto/ Solo cuando la devolución es de banco
	--Existe un último cobro con importe negativo y con origen devolución
	WHEN C.CN_COB IS NOT NULL AND C.CN_COB > 0 AND C.cblImporte IS NOT NULL AND C.cblImporte  < 0  AND C.cobMpc = @DOMICILIACION THEN  'DE'
	--AP: Aplazado/ cuando la fecha de vencimiento esta rellena y es distinta a la fecha de Vto original
	WHEN F.facFechaVto IS NOT NULL AND F.facFechaVtoOrig IS NOT NULL AND F.facFechaVto<>F.facFechaVtoOrig THEN 'AP'
	--NO: Notificado/ PENDIENTE de cobrar sin vencer. La fecha vencimiento de la factura no se ha cumplido aun 
	WHEN (ISNULL(F.facFechaVto, F.facFechaVtoOrig) >= @ahora) THEN 'NO'	
	ELSE '' END
	INTO #EDO_FAC
	FROM #FACS AS F
	LEFT JOIN #COBS AS C
	ON F.RN_FAC=1  --Ultima version de la factura
	AND C.RN_COB=1 --Ultimo cobro de esta factura
	AND F.facCod = C.facCod
	AND F.facPerCod = C.facPerCod
	AND F.facCtrCod = C.facCtrCod
	LEFT JOIN #EPS AS EPS
	ON  EPS.facCod = F.facCod
	AND EPS.facCtrCod = F.facCtrCod
	AND EPS.facPerCod = F.facPerCod
	AND EPS.RN_EP = 1; --Ultimo efecto pendiente
	
	--***DEBUG***
	SELECT * FROM #EDO_FAC;

	--[42] Estado: Efectos Pendientes
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, EF.facNumeroAqua
	, F.ctrTitDocIden
	, F.efePdteImporte
	, F.efePdteCod
	, C.TOTAL_EPCOB		--Total cobrado por efecto pendiente
	, C.CN_EPCOB		--Numero de cobros por efecto pendiente
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, [cobEstado] = CASE 
	--PD: Si el importe cobrado supera el importe total del efecto pendiente (Pendiente devolución)
	WHEN ROUND(ISNULL(C.TOTAL_EPCOB, 0), 2) > F.efePdteImporte  THEN 'PD' 
	--CD: Cobro detenido/Facturas
	WHEN EF.cobEstado IN ('CD') THEN EF.cobEstado
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_EPCOB, 0), 2) = F.efePdteImporte THEN 'CO'
	--VE: Vencido/ Facturas no cobradas y la fecha de vencimiento se ha cumplido. Prevalece sobre el aplazado
	WHEN F.efePdteFecVencimiento <  @ahora THEN 'VE'	
	--DE: Devuelto/ Solo cuando la devolución es de banco
	--Existe un último cobro con importe negativo y con origen devolución
	WHEN C.CN_COB IS NOT NULL AND C.CN_COB > 0 AND C.cblImporte IS NOT NULL AND C.cblImporte  < 0  AND C.cobMpc = @DOMICILIACION THEN  'DE'
	--AP: Aplazado
	WHEN EF.cobEstado IN ('AP') THEN EF.cobEstado
	--NO: Notificado/ PENDIENTE de cobrar sin vencer. La fecha vencimiento de la factura no se ha cumplido aun 
	WHEN F.efePdteFecVencimiento >=  @ahora THEN 'NO'
	ELSE '' END
	INTO #EDO_EPS
	FROM #EPS AS F
	INNER JOIN #EDO_FAC AS EF
	ON EF.facCod = F.facCod
	AND EF.facCtrCod = F.facCtrCod
	AND EF.facPerCod = F.facPerCod
	AND EF.facVersion = F.facVersion
	LEFT JOIN #COBS AS C
	ON  C.RN_EPCOB=1 --Ultimo cobro por efecto pendiente
	AND F.facCod = C.facCod
	AND F.facPerCod = C.facPerCod
	AND F.facCtrCod = C.facCtrCod
	AND F.efePdteCod = C.clefePdteCod;
	
	--*** DEBUG ****
	SELECT * FROM #EDO_EPS;
	
	--[50]Recibos
	SELECT EP.facCod, EP.facPerCod, EP.facCtrCod, EP.facVersion
	, EP.facNumeroAqua
	, EP.ctrTitDocIden
	, EP.cobEstado
	, ImporteRecibo= EP.efePdteImporte
	, Cobrado=ISNULL(EP.TOTAL_EPCOB, 0)
	, EP.efePdteCod
	, DeudaRecibo=EP.efePdteImporte-ISNULL(EP.TOTAL_EPCOB, 0)
	INTO #RECIBOS
	FROM #EDO_EPS AS EP
	WHERE EP.cobEstado NOT IN('CO', 'TR', 'CM', 'FR');
	
	
	INSERT INTO #RECIBOS
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion
	, F.facNumeroAqua
	, F.ctrTitDocIden
	, F.cobEstado
	, F.facTotal
	, ISNULL(F.TOTAL_COB, 0)
	, 0
	, deuda=F.facTotal-ISNULL(F.TOTAL_COB, 0)
	FROM #EDO_FAC AS F
	WHERE F.cobEstado NOT IN('CO', 'TR', 'CM', 'FR');

	
	

	SELECT R.*
	FROM #RECIBOS AS R
	WHERE R.ctrTitDocIden=@NIF

	UNION ALL
	SELECT facCod=0, facPerCod=0, facCtrCod=0, facVersion=0
	, ''
	, E.ctrTitDocIden
	, cobEstado='PD'
	, ImporteRecibo=0
	, Cobrado = EntregasCta
	, efePdteCod=0
	, DeudaRecibo = -1*E.EntregasCta
	FROM #EC AS E
	WHERE E.ctrTitDocIden=@NIF
	ORDER BY R.cobEstado, R.DeudaRecibo;
	
	--SELECT * FROM #RECIBOS;

	--END TRY
	
	--BEGIN CATCH
	--	SELECT  @p_errId_out = ERROR_NUMBER()
	--		 ,  @p_errMsg_out= ERROR_MESSAGE();
	--END CATCH

	DROP TABLE IF EXISTS  #ECTR;
	DROP TABLE IF EXISTS  #EC;
	DROP TABLE IF EXISTS  #FACTOTALES;
	DROP TABLE IF EXISTS  #FACS;
	DROP TABLE IF EXISTS  #EDO_FAC;
	DROP TABLE IF EXISTS  #EDO_EPS;
	DROP TABLE IF EXISTS  #COBS;
	DROP TABLE IF EXISTS  #EPS;
	DROP TABLE IF EXISTS  #RECIBOS;


--UPDATE U SET usrfpass	= GETDATE(), usrpass1='', usrpass2='', usrpass3=''
--, usrpass='XNF4R1B11mppeeKkP4VvA9THE+k1oHVHMEjE+6jBLw8MBIZI0+PDgOVw+7at04rtl0jErzjB/xx74lQwagl2CQ==' 
--FROM Usuarios AS U WHERE usrcod='gmdesousa'


--SELECT facNumeroAqua, facFechaVto, facFechaVtoOrig, faccod, facPerCod, facCtrCod, facVersion, facFechaRectif, facNumeroRectif 
--FROm facturas WHERE facPerCod='000001' AND facCtrCod=110139360 and facCod=1