DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);
SET @p_params= '<NodoXML><LI><FecDesde>20140106</FecDesde><FecHasta>20240529</FecHasta></LI></NodoXML>';
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
	BEGIN TRY
	
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

	/*
	select v1.ctrTitDocIden AS [NIF]
	INTO #ENTREGAPORNIF
	from cobros C
	inner join coblin on cblPpag = cobPpag and cblNum = cobNum and cblScd = cobScd
	inner join vContratoUltVersion v1 on v1.ctrcod = cobCtr
	INNER JOIN @params AS P ON
	(--Cobros de entrega a cuenta creados entre las fechas
	(P.fechaD IS NULL OR C.cobFec >= P.fechaD) AND
	(P.fechaH IS NULL OR C.cobFec < P.fechaH)
	)	where 
	cblPer = '999999'		
	group by v1.ctrTitDocIden, v1.ctrTitNom
	HAVING SUM(cblImporte) <> 0;

	CREATE TABLE #ENTREGASCUENTA (NIF VARCHAR(100) collate Modern_Spanish_CI_AS, Nombre VARCHAR(200) collate  Modern_Spanish_CI_AS, Factura VARCHAR(12) collate  Modern_Spanish_CI_AS, [Fecha Factura] DATE, estado VARCHAR(2) collate  Modern_Spanish_CI_AS, [Importe PAGO] MONEY, [Importe DEVOLUCION] MONEY)
	
	INSERT INTO #ENTREGASCUENTA
	select v1.ctrTitDocIden AS [NIF], v1.ctrTitNom AS Nombre, NULL AS Factura, CONVERT(DATE,cobFec) AS [Fecha Factura], 'PD' AS Estado, 0 AS [Importe PAGO],  SUM(cblImporte) AS [Importe DEVOLUCION] 	
	from cobros C
	inner join coblin on cblPpag = cobPpag and cblNum = cobNum and cblScd = cobScd
	inner join vContratoUltVersion v1 on v1.ctrcod = cobCtr
	INNER JOIN #ENTREGAPORNIF ENIF ON ENIF.NIF = V1.ctrTitDocIden
	INNER JOIN @params AS P ON
	(--Cobros de entrega a cuenta creados entre las fechas
	(P.fechaD IS NULL OR C.cobFec >= P.fechaD) AND
	(P.fechaH IS NULL OR C.cobFec < P.fechaH)
	)	where 
	cblPer = '999999'		
	group by v1.ctrTitDocIden, v1.ctrTitNom, cobFec
	HAVING SUM(cblImporte) <> 0;	
	*/
	
	DECLARE @sql NVARCHAR(MAX);
	--**************
	--[00]TOTAL FACTURAS: Sacamos las facturas que por fechas son las que conformarían el reporte
	-- #FACTOTALES
	SELECT T.ftfFacCod, T.ftfFacPerCod, T.ftfFacCtrCod, T.ftfFacVersion, T.ftfImporte
	INTO #FACTOTALES
	FROM dbo.fFacturas_TotalFacturado(NULL, NULL, NULL) AS T;

	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACTOTALES(ftfFacCod, ftfFacPerCod, ftfFacCtrCod, ftfFacVersion)';
	EXEC sp_executesql @sql;
	
	--**************
	--[01]FACTURAS: Sacamos las facturas que por fechas son las que conformarían el reporte
	-- #FACS: Filtramos las facturas que van para el informe
	SELECT F.facCod
	, F.facPerCod
	, F.facCtrCod
	, F.facVersion	
	, F.facFecha
	, F.facNumero
	, F.facSerCod
	, F.facNumeroAqua
	, F.facEstado
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
	--Facturas creadas dentro del rango de fechas
	INNER JOIN @params AS P
	ON  (P.fechaD IS NULL OR F.facFecha >= P.fechaD) 
	AND (P.fechaH IS NULL OR F.facFecha < P.fechaH)

	WHERE F.facNumero IS NOT NULL	--Se excluyen las prefacturas
	AND F.facEstado NOT IN (4,5);	--Se excluyen las (4) AGRUPADAS NI (5) TRASPASADAS. No es deuda 	

	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACS(facCod, facPerCod, facCtrCod, facVersion)';
	EXEC sp_executesql @sql;	
	
	--*** DEBUG ***
	--SELECT * FROM #FACS;
	
	
	--**********************
	--[02]RECTIFICATIVAS: Para saber las "Anuladas", tenemos que calcular el importe de las facturas rectificativas
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
	--[04]Para saber las que están en estado "Rechazada". Lo setearemos con un UPDATE 
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
	--[05]Borramos de la tabla #FACS las que no nos interesan, por su estado, para sacar el informe
	-- #FACS: Excluimos facturas que no se toman en cuenta para el informe
	DELETE FROM F
	FROM #FACS AS F
	WHERE F.facTotal IS NULL 
	OR F.facTotal = 0
	OR F.facNumero IS NULL	--PREFACTURAS
	OR F.facEstadoEmmasa='N' --ANULADAS
	OR F.facFechaRectif IS NOT NULL;


	--**** DEBUG *****
	SELECT * FROM #FACS;
	
	--**************
	--[20]Recuperamos los Efectos pendientes de las facturas:
	--Efectos Pendientes
	SELECT F.facCod
	, F.facCtrCod
	, F.facPerCod
	, F.facVersion
	, F.facNumeroAqua
	, F.facEstado
	, F.facEstadoEmmasa
	, F.facNumeroRectif
	, F.facImporteRectif
	, F.facFechaVto
	, F.facFechaVtoOrig
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
	--SELECT * FROM #EPS;

	
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
	


	--[40] Facturas
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumeroAqua
	, F.facEstado, F.facEstadoEmmasa
	, F.facTotal
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
	--AN: Anulado/ Facturas anuladas
	--Además de tener la original rellenos los campos de rectificación la rectificativa tiene importe 0
	WHEN F.facNumeroRectif IS NOT NULL AND F.facImporteRectif = 0 THEN 'AN'
	--TR: Traspasado/Facturas con facEstado = 5
	WHEN (F.facEstado = 5) THEN 'TR'
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
	WHEN (F.facFechaVto IS NOT NULL) AND (F.facFechaVtoOrig IS NOT NULL AND F.facFechaVto<>F.facFechaVtoOrig) THEN 'AP'
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


	--[50] Efectos Pendientes
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumeroAqua
	, F.facEstado, F.facEstadoEmmasa
	, F.efePdteImporte
	, TOTAL_EPS = NULL	--Totalizacion de los efectos pendientes
	, C.TOTAL_EPCOB		--Total cobrado por efecto pendiente
	, C.CN_EPCOB		--Numero de cobros por efecto pendiente
	, CN_COB_COMP=NULL	--Numero de cobros por compensación
	, CN_EP=NULL		--Numero de efectos pendientes por factura
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, [cobEstado] = CASE 
	--PD: Si el importe cobrado supera el importe total del efecto pendiente (Pendiente devolución)
	WHEN ROUND(ISNULL(C.TOTAL_EPCOB, 0), 2) > F.efePdteImporte  THEN 'PD' 
	--AN: Anulado/ Facturas anuladas
	--Además de tener la original rellenos los campos de rectificación la rectificativa tiene importe 0
	WHEN F.facNumeroRectif IS NOT NULL AND F.facImporteRectif = 0 THEN 'AN'	
	--TR: Traspasado/Facturas con facEstado = 5
	WHEN (F.facEstado = 5) THEN 'TR'
	--CD: Cobro detenido/Facturas con facEstado = 6
	WHEN (F.facEstado = 6) THEN 'CD'
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_EPCOB, 0), 2) = F.efePdteImporte THEN 'CO'
	--VE: Vencido/ Facturas no cobradas y la fecha de vencimiento se ha cumplido. Prevalece sobre el aplazado
	WHEN F.efePdteFecVencimiento <  @ahora THEN 'VE'	
	--DE: Devuelto/ Solo cuando la devolución es de banco
	--Existe un último cobro con importe negativo y con origen devolución
	WHEN C.CN_COB IS NOT NULL AND C.CN_COB > 0 AND C.cblImporte IS NOT NULL AND C.cblImporte  < 0  AND C.cobMpc = @DOMICILIACION THEN  'DE'
	--AP: Aplazado/ cuando la fecha de vencimiento esta rellena y es distinta a la fecha de Vto original
	WHEN F.facFechaVto IS NOT NULL AND F.facFechaVtoOrig IS NOT NULL AND F.facFechaVto<>F.facFechaVtoOrig THEN 'AP'
	--NO: Notificado/ PENDIENTE de cobrar sin vencer. La fecha vencimiento de la factura no se ha cumplido aun 
	WHEN F.efePdteFecVencimiento >=  @ahora THEN 'NO'
	ELSE '' END
	INTO #EDO_EPS
	FROM #EPS AS F	
	LEFT JOIN #COBS AS C
	ON  C.RN_EPCOB=1 --Ultimo cobro por efecto pendiente
	AND F.facCod = C.facCod
	AND F.facPerCod = C.facPerCod
	AND F.facCtrCod = C.facCtrCod
	AND F.efePdteCod = C.clefePdteCod;
	
	



	--SELECT * FROM #FACS WHERE facNumeroRectif IS NOT NULL;
	
	/*

	
	

	--**************
	--[41] Finalmente tenemos todo para calcular el ESTADO DE LOS PAGOS.
	---- #EDOCOB: Tabla con las facturas de la consulta y su ESTADO DE PAGO
	SELECT R.facCod
	, R.facPerCod
	, R.facCtrCod
	, R.facVersion
	, R.efePdteCod 
	, R.efePdteScd
	--***************
	, R.facNumeroAqua
	, R.facTotal
	--Nos quedamos con una sola versión de contrato. La mayor:
	, MAX(R.facCtrVersion) OVER (PARTITION BY R.facCtrCod) AS ctrVersion 
	, R.efePdteImporte
	, R.efePdteTotal
	, R.efePdteFecVencimiento
	--***************
	, R.ultCobNum 
	, R.totalCobrado
	, R.facNumCobros	
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, CASE 
	--FR: Fraccionado/ una factura con efectos pendientes
	WHEN R.efePdteCod IS NULL AND R.efePdtes IS NOT NULL AND R.efePdtes>0 THEN 'FR'

	--PD: Si el importe deuda es negativo (Pendiente devolución)
	WHEN ROUND(COALESCE(R.efePdteImporte, FF.facTotal, 0),2) < ROUND(ISNULL(R.totalCobrado, 0),2) THEN 'PD'

	--CM1: Compensando / Facturas cobradas por el punto de pago compensación
	--WHEN (R.efePdteCod IS NULL AND ROUND(R.totalCobrado,2) < ROUND(R.facTotal,2)) AND R.ultCobNum IS NOT NULL AND R.facNumCobros = R.facNumCobros_Comp THEN 'CM1' 

	--CM: Compensando / Facturas cobradas por el punto de pago compensación
	WHEN (R.efePdteCod IS NULL AND ROUND(R.totalCobrado,2) >= ROUND(R.facTotal,2)) AND R.ultCobNum IS NOT NULL AND R.facNumCobros = R.facNumCobros_Comp THEN 'CM' 

	--AN: Anulado/ Facturas anuladas
	--Además de tener la original rellenos los campos de rectificación la rectificativa tiene importe 0
	WHEN FF.facNumeroRectif IS NOT NULL AND FF.facImporteRectif = 0 THEN 'AN'

	--TR: Traspasado/Facturas con facEstado = 5
	WHEN (FF.facEstado = 5) THEN 'TR'

	--CD: Cobro detenido/Facturas con facEstado = 6
	WHEN (FF.facEstado = 6) THEN 'CD'	

	--CO: Cobrado/ factura cobrada
	WHEN (R.ultCobNum IS NOT NULL AND R.totalCobrado IS NOT NULL) AND
	(	--Factura cobrada
		(R.efePdteCod IS NULL	  AND ROUND(R.totalCobrado,2) >= ROUND(R.facTotal,2))  OR
		--Efecto pendiente cobrado
		(R.efePdteCod IS NOT NULL AND ROUND(R.totalCobrado, 2) >= ROUND(R.efePdteImporte,2))
	) THEN 'CO'
	
	--VE: Vencido/ Facturas no cobradas y la fecha de vencimiento se ha cumplido. Prevalece sobre el aplazado
	WHEN (R.efePdteCod IS NOT NULL AND R.efePdteFecVencimiento <  @ahora) THEN 'VE'
	WHEN (R.efePdteCod IS NULL AND ISNULL(FF.facFechaVto, FF.facFechaVtoOrig) <  @ahora) THEN 'VE'

	--DE: Devuelto/ Solo cuando la devolución es de banco
	--Existe un último cobro con importe negativo y con origen devolución
	WHEN R.ultCobNum IS NOT NULL AND R.ultCobImporte IS NOT NULL AND R.ultCobImporte < 0  AND R.ultCobMpc = @DOMICILIACION THEN  'DE'

	--AP: Aplazado/ cuando la fecha de vencimiento esta rellena y es distinta a la fecha de Vto original
	WHEN (FF.facFechaVto IS NOT NULL) AND (FF.facFechaVtoOrig IS NOT NULL AND FF.facFechaVto<>FF.facFechaVtoOrig) THEN 'AP'
	
	--NO: Notificado/ PENDIENTE de cobrar sin vencer. La fecha vencimiento de la factura no se ha cumplido aun 
	WHEN (R.efePdteCod IS NOT NULL AND R.efePdteFecVencimiento >=  @ahora) THEN 'NO'
	WHEN (R.efePdteCod IS NULL AND ISNULL(FF.facFechaVto, FF.facFechaVtoOrig) >= @ahora) THEN 'NO'

	--IM: Impagado/	incobrables ver funcional
	--CS: Cobrado salvo devolución/	NO SE USA
	--DC: Dividido por compensación/ NO SE PODRA OBTENER EN ACUAMA
	ELSE '' END 
	AS [cobEstado]
	INTO #EDOCOB
	FROM #RECIBOCOB AS R
	LEFT JOIN #FACS AS FF
	ON R.facCod = FF.facCod
	AND R.facPerCod = FF.facPerCod
	AND R.facCtrCod = FF.facCtrCod
	AND R.facVersion = FF.facVersion;

	--**************
	--[RR] RESULTADO FINAL:
	--**************

	--[R1] Filtramos por estado del pago.
	---- #RESULT: Filtramos las facturas+efectos pendientes por su estado de pago
	SELECT IDENTITY(INT,1,1) AS ID
	, R.facCod
	, R.facPerCod
	, R.facCtrCod
	, R.facVersion
	, R.facNumeroAqua
	, R.efePdteCod
	, R.efePdteScd
	, R.efePdteFecVencimiento
	, E.cobEstado
	, E.efePdteImporte
	, E.totalCobrado
	, E.ultCobNum
	INTO #RESULT
	FROM #RECIBOCOB AS R
	LEFT JOIN #EDOCOB AS E
	ON E.facCod = R.facCod
	AND E.facPerCod = R.facPerCod
	AND E.facCtrCod = R.facCtrCod
	AND E.facVersion= R.facVersion
	AND ((R.efePdteCod IS NULL AND E.efePdteCod IS NULL) OR  R.efePdteCod = E.efePdteCod)
	AND ((R.efePdteScd IS NULL AND E.efePdteScd IS NULL) OR  R.efePdteScd = E.efePdteScd)
	WHERE E.cobEstado NOT IN ('CO', 'TR', 'CM','FR')
	ORDER BY R.facNumeroAqua, R.efePdteCod;

	--********************
	--[R2]Estados de los contratos
	CREATE TABLE #EDOCTR(
	  ctrcod INT	
	, ctrversion INT	
	, ctrUsoCod INT
	, ctrZonCod VARCHAR(4)	
	, ctrfecini DATETIME
	, ctrfecanu	DATETIME
	, esDomiciliado BIT
	, Estado VARCHAR(1))

	INSERT INTO #EDOCTR
	EXEC InformesExcel.contratosEstados_EMMASA;

	--**************
	--[R3] Columnas del resultado relevantes para la salida del informe.
	---- #REPORT: Filtramos las facturas+efectos pendientes por su estado de pago	
	SELECT R.ID
	, R.facCod
	, R.facPerCod
	, R.facCtrCod
	, R.facVersion
	, R.facNumeroAqua
	, CAST(R.efePdteCod AS VARCHAR(25)) AS efePdteCod
	, R.efePdteScd
	, R.cobEstado
	, R.efePdteFecVencimiento

	, F.facEstadoEmmasa
	, F.facFecha
	, YEAR(F.facFecha) AS Año
	, F.facTotal
	, F.facFechaVtoOrig
	, IIF(F.facFechaVto IS NOT NULL AND F.facFechaVtoOrig IS NOT NULL AND F.facFechaVto<> F.facFechaVtoOrig, F.facFechaVto, NULL) AS facFechaVto
	, F.facSerCod
	, S.serdesc

	, C.ctrFicticio
	, ISNULL(C.ctrTitExtCorte, 0) AS ctrTitExtCorte
	, C.ctrTitDocIden
	, C.ctrTitNom
	, CC.Estado AS ctrEstado
	, C.ctrUsoCod
	, U.usodes
	--***************
	, ultCobNum
	, COALESCE(R.efePdteImporte, F.facTotal, 0) AS facturado
	, ISNULL(R.totalCobrado, 0) AS cobrado
	, COALESCE(R.efePdteImporte, F.facTotal, 0) - ISNULL(R.totalCobrado, 0) AS deuda
	INTO #REPORT
	FROM #RESULT AS R
	LEFT JOIN #FACS AS F
	ON F.facCod = R.facCod
	AND F.facPerCod = R.facPerCod
	AND F.facCtrCod = R.facCtrCod
	AND F.facVersion = R.facVersion
	LEFT JOIN dbo.contratos AS C
	ON C.ctrcod = F.facCtrCod
	AND C.ctrversion = F.facCtrVersion
	LEFT JOIN #EDOCTR AS CC
	ON CC.ctrcod = C.ctrcod
	LEFT JOIN dbo.usos AS U
	ON U.usocod = C.ctrUsoCod
	LEFT JOIN dbo.series AS S
	ON S.sercod = F.facSerCod;

	
	--********************
	--DataTable[3]:  Datos
	--[1/2] Salida para la plantilla del informe
	SELECT  
	 ctrTitDocIden AS [NIF]
	, ctrTitNom AS [Nombre]
	, facNumeroAqua AS [Factura]
	, facFecha AS [Fecha Factura]	
	FROM #REPORT
	--MUY IMPORTANTE garantizar el orden deterministico en ambas tablas
	ORDER BY Año, facNumeroAqua, ID;

	--********************
	--DataTable[4]:  Datos
	--[2/2] Salida para la plantilla del informe
	SELECT 
	--IIF(deuda < 0, 'DEVOLUCION', 'PAGO') AS Tipo
	--, efePdteCod AS [Efecto Pendiente] 
	 cobEstado AS [Estado]
	--, facturado AS [Importe Facturado]
	, deuda * IIF(cobEstado IS NOT NULL AND cobEstado='PD', 0, 1) AS [Importe PAGO]
	, deuda * IIF(cobEstado IS NOT NULL AND cobEstado='PD', -1, 0) AS [Importe DEVOLUCION]
	--, FORMAT(facFecha, 'dd/MM/yyyy') AS [Fecha Creación]
	--, FORMAT(facFechaVtoOrig, 'dd/MM/yyyy') AS [Fecha VTO. Origen]
	--, FORMAT(facFechaVto, 'dd/MM/yyyy') AS [Fecha Nuevo VTO]
	FROM #REPORT
	--MUY IMPORTANTE garantizar el orden deterministico en ambas tablas
	ORDER BY Año, facNumeroAqua, ID;

	SELECT 
	 ctrTitDocIden AS [NIF]
	, ctrTitNom AS [Nombre]
	, facNumeroAqua AS [Factura]
	, facFecha AS [Fecha Factura]	
	, cobEstado AS [Estado]	
	, deuda * IIF(cobEstado IS NOT NULL AND cobEstado='PD', 0, 1) AS [Importe PAGO]
	, deuda * IIF(cobEstado IS NOT NULL AND cobEstado='PD', -1, 0) AS [Importe DEVOLUCION]
	FROM #REPORT AS R
	UNION ALL
	SELECT 
	NIF,
	Nombre,
	Factura,
	[Fecha Factura],
	estado,
	[Importe PAGO],
	[Importe DEVOLUCION]
	FROM #ENTREGASCUENTA
	ORDER BY NIF, [Factura], [Fecha Factura]	
	*/

	END TRY
	
	BEGIN CATCH
		SELECT  @p_errId_out = ERROR_NUMBER()
			 ,  @p_errMsg_out= ERROR_MESSAGE();
	END CATCH


	DROP TABLE IF EXISTS  #FACTOTALES;
	DROP TABLE IF EXISTS  #FACS;
	DROP TABLE IF EXISTS  #EDO_FAC;
	DROP TABLE IF EXISTS  #EDO_EPS;

	DROP TABLE IF EXISTS  #COBS;
	DROP TABLE IF EXISTS  #EPS;



	
	IF OBJECT_ID('tempdb.dbo.#COBROS', 'U') IS NOT NULL  
	DROP TABLE dbo.#COBROS;

	IF OBJECT_ID('tempdb.dbo.#RECIBOS', 'U') IS NOT NULL  
	DROP TABLE dbo.#RECIBOS;

	IF OBJECT_ID('tempdb.dbo.#RECIBOCOB', 'U') IS NOT NULL  
	DROP TABLE dbo.#RECIBOCOB;
	
	IF OBJECT_ID('tempdb.dbo.#EDOCOB', 'U') IS NOT NULL  
	DROP TABLE dbo.#EDOCOB;

	--***************
	IF OBJECT_ID('tempdb.dbo.#EDOCTR', 'U') IS NOT NULL  
	DROP TABLE dbo.#EDOCTR;

	IF OBJECT_ID('tempdb.dbo.#RESULT', 'U') IS NOT NULL  
	DROP TABLE dbo.#RESULT;

	IF OBJECT_ID('tempdb.dbo.#REPORT', 'U') IS NOT NULL  
	DROP TABLE dbo.#REPORT;

	IF OBJECT_ID('tempdb.dbo.#ENTREGAPORNIF', 'U') IS NOT NULL  
	DROP TABLE dbo.#ENTREGAPORNIF;

	IF OBJECT_ID('tempdb.dbo.#ENTREGASCUENTA', 'U') IS NOT NULL  
	DROP TABLE dbo.#ENTREGASCUENTA;
	


GO


