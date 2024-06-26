
DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);
SET @p_params= '<NodoXML><LI><FecDesde>20140601</FecDesde><FecHasta>20240529</FecHasta></LI></NodoXML>';
/*
EXEC [InformesExcel].[DeudaAuditoresSevilla_EMMASA]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
SELECT @p_errMsg_out


ALTER PROCEDURE [InformesExcel].[DeudaAuditoresSevilla_EMMASA]
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
	--*** DEBUG ****
	DECLARE @NIF VARCHAR(25);-- = '42086521V';
	--**************

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
	--CM - Compensaci�n.
	DECLARE @COMPENSACION AS INT;
	SELECT @COMPENSACION=mpccod 
	FROM dbo.medpc AS M WHERE M.mpcdes = 'Compensaci�n';

	--DE - Devuelto.
	DECLARE @DOMICILIACION AS INT = 0;
	SELECT @DOMICILIACION=mpccod 
	FROM dbo.medpc AS M WHERE M.mpcdes = 'Domiciliaci�n bancar';

	--[01]Entregas a cuenta: pendientes por cliente
	SELECT CC.clicod
	, clidociden=UPPER(TRIM(CC.clidociden))
	, clinom=UPPER(TRIM(CC.clinom))
	, EntregasCta = SUM(CL.cblImporte)
	, Fecha = MIN(C.cobFec)
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
	LEFT JOIN dbo.clientes AS CC
	ON CC.clicod = CTR.ctrTitCod
	GROUP BY CC.clicod, UPPER(TRIM(CC.clidociden)), UPPER(TRIM(CC.clinom))
	HAVING SUM(CL.cblImporte)<>0;
	
	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#ECTR] = '#ECTR', * FROM #ECTR WHERE clidociden=@NIF;
	--**************
	
	--[02]Entregas a cuenta: pendientes por documento identidad y nombre
	SELECT C.*
	, Total_EntregasCta = SUM(EntregasCta) OVER(PARTITION BY clidociden, clinom)
	--RN=1: Linea mas reciente de efecto pendiente con su total
	, RN = ROW_NUMBER() OVER(PARTITION BY clidociden, clinom ORDER BY Fecha DESC)
	, CN = COUNT(clidociden) OVER(PARTITION BY clidociden, clinom)
	INTO #EC
	FROM #ECTR AS C;
	
	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#EC]='#EC', * FROM #EC WHERE clidociden=@NIF;
	--**************

	--**************
	--[10]TOTAL FACTURAS: Sacamos las facturas que por fechas son las que conformar�an el reporte
	-- #FACTOTALES
	DECLARE @sql NVARCHAR(MAX);
	
	SELECT T.ftfFacCod, T.ftfFacPerCod, T.ftfFacCtrCod, T.ftfFacVersion, T.ftfImporte
	INTO #FACTOTALES
	FROM _FACTOTALES AS T;
	--FROM dbo.fFacturas_TotalFacturado(NULL, NULL, NULL) AS T;
	
	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACTOTALES(ftfFacCod, ftfFacPerCod, ftfFacCtrCod, ftfFacVersion)';
	EXEC sp_executesql @sql;
	
	--**************
	--[11]FACTURAS: Sacamos las facturas que por fechas son las que conformar�an el reporte
	-- #FACS: Filtramos las facturas que van para el informe
	SELECT F.facCod
	, F.facPerCod
	, F.facCtrCod
	, F.facVersion	
	, F.facCtrVersion
	, F.facNumero
	, F.facEstado
	, F.facNumeroAqua
	--Hay NIFs que no coinciden con el del titular, nos quedamos con el del cliente titular
	, CL.clidociden 
	, C.ctrTitDocIden 
	, C.ctrTitCod
	, C.ctrTitNom
	--**********************
	, F.facFechaRectif
	, F.facNumeroRectif
	, F.facSerieRectif
	, F.facFechaVto
	, F.facFechaVtoOrig
	, F.facFecha
	--**********************
	, facTotal = ISNULL(FT.ftfImporte, 0)
	, facImporteRectif =  CAST(NULL AS MONEY)
	--**********************
	, facRfsCodigo = CAST(NULL AS INT)
	, '' AS facEstadoEmmasa
	--Los Efectos Pendientes no van por versi�n de factura as� que...
	--Para saber cual es la �ltima version de la factura y asociar a ella los efectos pendientes
	--RN_FAC=1: Ultima vesi�n de la factura
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
	LEFT JOIN dbo.clientes AS CL
	ON CL.clicod = C.ctrTitCod
	WHERE F.facNumero IS NOT NULL	--Se excluyen las prefacturas
	AND F.facEstado NOT IN (4,5)	--Se excluyen las (4) AGRUPADAS NI (5) TRASPASADAS-TR-. No es deuda 	
	AND (@NIF IS NULL OR CL.clidociden=@NIF);

	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACS(facCod, facPerCod, facCtrCod, facVersion)';
	EXEC sp_executesql @sql;	


		
	--*** DEBUG ***
	--SELECT * FROM #FACS;
	--Hay NIFs que no coinciden con el del titular, nos quedamos con el del cliente titular
	--SELECT * FROM #FACS WHERE clidociden <> ctrTitDocIden;
	--SELECT * FROM #FACS WHERE clidociden <> ctrTitDocIden AND SUBSTRING(clidociden, 1, 8)=SUBSTRING(ctrTitDocIden,1, 8);
	--************
		
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
	--[13]Para saber las que est�n en estado "Rechazada". Lo setearemos con un UPDATE 
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
							--V	Retenida pendiente de Validaci�n / NO APLICA	
							--A	Retenida pendiente de Aprobaci�n / NO APLICA	
							--E: Rechazada pendiente de Expediente / Facturas incluidas en una propuesta de refacturaci�n
							WHEN FT.rfsCodigo IS NOT NULL THEN 'E'
							--N: Anulada/Facturas anuladas
							WHEN F.facNumeroRectif IS NOT NULL AND F.facImporteRectif = 0 THEN  'N'
							--R	Rechazada pendiente de Revisi�n	
							WHEN F.facNumeroRectif IS NOT NULL AND F.facImporteRectif <> 0 THEN  'R'
							--B: Albar�n/Facturas con estado 7
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


	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#FACS] = '#FACS', * FROM #FACS WHERE clidociden=@NIF ORDER BY facPerCod;
	--**************
	
	--**************
	--[20]Recuperamos los Efectos pendientes de las facturas:
	--#EPS: Efectos Pendientes
	SELECT F.facCod
	, F.facCtrCod
	, F.facPerCod
	, F.facVersion
	, F.clidociden
	, F.ctrTitDocIden
	, F.ctrTitNom
	, F.ctrTitCod
	, EP.efePdteCod
	, EP.efePdteScd
	, EP.efePdteImporte
	, EP.efePdteFecVencimiento
	--Totalizaci�n de los efectos pendientes por factura
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

	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#EPS]='#EPS', * FROM #EPS;
	--**************
	
	--**************
	--[30]Totalizamos los cobros por FACTURA (sin version)
	--Para calcular el estado del pago necesitamos detalles del total de los cobros asi como el �ltimo cobro 
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
	--CN_COB: N�mero de cobros de compensaci�n por factura
	, CN_COB_COMP = SUM(IIF(CB.cobMpc=@COMPENSACION, 1, 0)) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod)
	--CN_COB: N�mero de cobros por factura
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
	--CN_EPCOB: N�mero de cobros por efectos pendientes
	, CN_EPCOB = COUNT(CB.cobNum) OVER (PARTITION BY F.facCod , F.facPerCod, F.facCtrCod, CLEP.clefePdteCod)
	INTO #COBS
	FROM  #FACS AS F	
	INNER JOIN dbo.cobros AS CB
	ON F.RN_FAC = 1 --RN_FAC=1: Ultima vesi�n de la factura
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
	
	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#COBS]='#COBS', * FROM #COBS ORDER BY facCtrCod, facPerCod, RN_COB;
	--**************
	
	--[41] Estado: Facturas
	--#EDO_FAC
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumeroAqua
	, F.facTotal
	, F.clidociden
	, F.ctrTitDocIden
	, F.ctrTitNom
	, F.ctrTitCod
	, F.facFecha
	, EPS.TOTAL_EPS --Totalizacion de los efectos pendientes
	, C.TOTAL_COB	--Total cobrado por factura
	, C.CN_COB		--Numero de cobros
	, C.CN_COB_COMP --Numero de cobros por compensaci�n
	, EPS.CN_EP		--Numero de efectos pendientes por factura
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, [cobEstado] = CASE 
	--FR: Fraccionado/ una factura con efectos pendientes
	WHEN  EPS.CN_EP IS NOT NULL AND EPS.CN_EP>0 THEN 'FR'
	--PD: Si el importe cobrado supera el importe total de la factura (Pendiente devoluci�n)
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) > F.facTotal  THEN 'PD' 
	--CM: Compensando / Facturas cobradas por el punto de pago compensaci�n (todos los cobros son por compensaci�n)
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) = F.facTotal AND C.CN_COB IS NOT NULL AND C.CN_COB > 0 AND C.CN_COB = C.CN_COB_COMP THEN 'CM' 
	--CD: Cobro detenido/Facturas con facEstado = 6
	WHEN (F.facEstado = 6) THEN 'CD'
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) = F.facTotal THEN 'CO'
	--VE: Vencido/ Facturas no cobradas y la fecha de vencimiento se ha cumplido. Prevalece sobre el aplazado
	WHEN ISNULL(F.facFechaVto, F.facFechaVtoOrig) <  @ahora THEN 'VE'
	--DE: Devuelto/ Solo cuando la devoluci�n es de banco
	--Existe un �ltimo cobro con importe negativo y con origen devoluci�n
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
	
	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#EDO_FAC] = '#EDO_FAC', * FROM #EDO_FAC;
	--**************
	
	--[42] Estado: Efectos Pendientes
	--#EDO_EPS
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, EF.facNumeroAqua
	, F.clidociden
	, F.ctrTitDocIden
	, F.ctrTitNom
	, F.ctrTitCod
	, F.efePdteImporte
	, F.efePdteCod
	, F.efePdteFecVencimiento
	, C.TOTAL_EPCOB		--Total cobrado por efecto pendiente
	, C.CN_EPCOB		--Numero de cobros por efecto pendiente
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, [cobEstado] = CASE 
	--PD: Si el importe cobrado supera el importe total del efecto pendiente (Pendiente devoluci�n)
	WHEN ROUND(ISNULL(C.TOTAL_EPCOB, 0), 2) > F.efePdteImporte  THEN 'PD' 
	--CD: Cobro detenido/Facturas
	WHEN EF.cobEstado IN ('CD') THEN EF.cobEstado
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_EPCOB, 0), 2) = F.efePdteImporte THEN 'CO'
	--VE: Vencido/ Facturas no cobradas y la fecha de vencimiento se ha cumplido. Prevalece sobre el aplazado
	WHEN F.efePdteFecVencimiento <  @ahora THEN 'VE'	
	--DE: Devuelto/ Solo cuando la devoluci�n es de banco
	--Existe un �ltimo cobro con importe negativo y con origen devoluci�n
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
	IF(@NIF IS NOT NULL)
	SELECT [#EDO_EPS]='#EDO_EPS', * FROM #EDO_EPS;
	--**************
	
	--[50]#RECIBOS
	--Efectos Pendientes
	SELECT EP.facCod, EP.facPerCod, EP.facCtrCod, EP.facVersion
	, EP.facNumeroAqua
	, EP.clidociden
	, EP.ctrTitDocIden
	, EP.ctrTitNom
	, EP.ctrTitCod
	, EP.cobEstado
	, ImporteRecibo= EP.efePdteImporte
	, Cobrado=ISNULL(EP.TOTAL_EPCOB, 0)
	, EP.efePdteCod
	, DeudaRecibo=EP.efePdteImporte-ISNULL(EP.TOTAL_EPCOB, 0)
	, Fecha = CAST(EP.efePdteFecVencimiento AS DATE)
	INTO #RECIBOS
	FROM #EDO_EPS AS EP
	WHERE EP.cobEstado NOT IN('CO', 'TR', 'CM', 'FR');
	

	--Facturas
	INSERT INTO #RECIBOS
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion
	, F.facNumeroAqua
	, F.clidociden
	, F.ctrTitDocIden
	, F.ctrTitNom
	, F.ctrTitCod
	, F.cobEstado
	, ImporteRecibo = F.facTotal
	, Cobrado = ISNULL(F.TOTAL_COB, 0)
	, efePdteCod = 0
	, DeudaRecibo=F.facTotal-ISNULL(F.TOTAL_COB, 0)
	, [Fecha] = F.facFecha
	FROM #EDO_FAC AS F
	WHERE F.cobEstado NOT IN('CO', 'TR', 'CM', 'FR');

	/*
	SELECT R.facCod, R.facPerCod, R.facCtrCod, R.facVersion
	, R.facNumeroAqua
	, R.clidociden
	, R.cobEstado
	, R.ImporteRecibo
	, R.Cobrado
	, R.efePdteCod
	, R.DeudaRecibo
	FROM #RECIBOS AS R
	WHERE (@NIF IS NULL OR  R.clidociden=@NIF)
	
	UNION ALL
	SELECT facCod=0, facPerCod=0, facCtrCod=0, facVersion=0
	, facNumeroAqua = ''
	, E.clidociden
	, cobEstado='PD'
	, ImporteRecibo=0
	, Cobrado = EntregasCta
	, efePdteCod=0
	, DeudaRecibo = -1*E.Total_EntregasCta
	FROM #EC AS E
	WHERE RN=1 AND (@NIF IS NULL OR E.clidociden=@NIF)
	ORDER BY R.cobEstado, R.DeudaRecibo;
	

	WITH CLI AS(
	--Para quedarnos con la ultima instancia del mismo cliente por DNI
	SELECT  clidociden = UPPER(LTRIM(LTRIM(C.clidociden)))
	, clinom = UPPER(LTRIM(LTRIM(C.clinom)))
	, fecha = ISNULL(C.cliFecUltMod, C.cliFecReg)
	--RN=1: Para quedarnos con el ultimo cliente del mismo DNI
	, RN = ROW_NUMBER() OVER (PARTITION BY  UPPER(LTRIM(LTRIM(C.clidociden))) ORDER BY ISNULL(C.cliFecUltMod, C.cliFecReg) DESC)
	FROM dbo.clientes AS C)
	*/
	--Facturas y Efectos Pendientes
	WITH T AS(
	SELECT [NIF] = R.clidociden
	, [Nombre] = R.ctrTitNom
	, [Factura] = R.facNumeroAqua
	, [Fecha Factura] = CAST(R.Fecha AS DATE)
	, [Estado] = R.cobEstado
	, [Importe RECIBO] = R.ImporteRecibo
	, [Importe PAGO] = IIF(cobEstado IS NOT NULL AND cobEstado='PD', 0, R.DeudaRecibo)
	, [Importe DEVOLUCION] = IIF(cobEstado IS NOT NULL AND cobEstado='PD', R.DeudaRecibo*-1, 0)
	FROM #RECIBOS AS R
	WHERE (@NIF IS NULL OR  R.clidociden=@NIF)


	UNION ALL
	SELECT [NIF] = E.clidociden
	, [Nombre] = E.clinom
	, [Factura] = NULL
	, [Fecha Factura] = CAST(E.Fecha AS DATE)
	, [Estado] = 'PD'
	, [Importe RECIBO] = NULL
	, [Importe PAGO] = 0
	, [Importe DEVOLUCION] = E.Total_EntregasCta

	FROM #EC AS E
	--RN=1: Para quedarnos solo con el efecto pendiente mas reciente por NIF y Nombre
	WHERE RN=1 AND (@NIF IS NULL OR E.clidociden=@NIF)
	--ORDER BY [NIF], [Nombre], [Factura]
	)

	SELECT * 
	--, RN = ROW_NUMBER() OVER (PARTITION BY NIF, Nombre ORDER BY [Factura] DESC)
	--, DEUDA = SUM([Importe PAGO] ) OVER (PARTITION BY NIF, Nombre)
	--, DEVOLUCION= SUM([Importe DEVOLUCION]) OVER (PARTITION BY NIF, Nombre)
	FROM T;

	END TRY
	
	BEGIN CATCH
		SELECT  @p_errId_out = ERROR_NUMBER()
			 ,  @p_errMsg_out= ERROR_MESSAGE();
	END CATCH

	DROP TABLE IF EXISTS  #ECTR;
	DROP TABLE IF EXISTS  #EC;
	DROP TABLE IF EXISTS  #FACTOTALES;
	DROP TABLE IF EXISTS  #FACS;
	DROP TABLE IF EXISTS  #EDO_FAC;
	DROP TABLE IF EXISTS  #EDO_EPS;
	DROP TABLE IF EXISTS  #COBS;
	DROP TABLE IF EXISTS  #EPS;
	DROP TABLE IF EXISTS  #RECIBOS;

GO