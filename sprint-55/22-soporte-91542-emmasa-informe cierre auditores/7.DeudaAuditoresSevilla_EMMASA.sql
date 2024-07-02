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
	DECLARE @NIF VARCHAR(25);--= '00859989L';
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
	--CM - Compensación.
	DECLARE @COMPENSACION AS INT;
	SELECT @COMPENSACION=mpccod 
	FROM dbo.medpc AS M WHERE M.mpcdes = 'Compensación';

	--DE - Devuelto.
	DECLARE @DOMICILIACION AS INT = 0;
	SELECT @DOMICILIACION=mpccod 
	FROM dbo.medpc AS M WHERE M.mpcdes = 'Domiciliación bancar';

	--**************
	--[01]Entregas a cuenta, como se saca en el informe de deuda 
	--[dbo].[Excel_ExcelConsultas.DeudaTipoFactura_EMMASA]
	--Enlazamos con clientes porque vemos que los DNI en contratos no esta de todo correcto
	SELECT [Contrato] = IIF(v1.ctrFicticio=1, NULL, V1.ctrcod),
	[NIF] = UPPER(TRIM(V1.ctrTitDocIden)), 
	[Nombre]=UPPER(TRIM(V1.ctrTitNom)),
	[Importe DEUDA] = SUM(cblImporte),
	[Fecha Factura] = C.cobFec
	INTO #ECxDEUDA
	FROM dbo.cobros AS C
	INNER JOIN dbo.coblin AS CL 
	ON CL.cblPpag = C.cobPpag 
	AND CL.cblNum = C.cobNum 
	AND CL.cblScd = C.cobScd
	AND CL.cblPer = '999999'		
	INNER JOIN dbo.vContratoUltVersion AS V1 
	ON V1.ctrcod = C.cobCtr
	INNER JOIN dbo.usos AS U 
	ON V1.ctrUsoCod = U.usocod
	--***************************************
	--Documento de identidad:
	--Tener en cuenta que al tomar los datos del contrato el DNI puede estar truncado
	LEFT JOIN dbo.clientes AS CC
	ON CC.clicod = V1.ctrTitCod
	--***************************************
	INNER JOIN @params AS P ON
	(--Cobros de entrega a cuenta creados entre las fechas
	(P.fechaD IS NULL OR C.cobFec >= P.fechaD) AND
	(P.fechaH IS NULL OR C.cobFec < P.fechaH))	
	GROUP BY UPPER(TRIM(V1.ctrTitDocIden))
	, UPPER(TRIM(V1.ctrTitNom))
	, C.cobFec
	, IIF(V1.ctrFicticio=1, NULL, V1.ctrcod)
	HAVING SUM(cblImporte) <> 0;

	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#EC]='#ECxDEUDA', * FROM #ECxDEUDA WHERE [NIF]=@NIF;
	--**************


	--**************
	--[10]TOTAL FACTURAS: Sacamos los totales por factura una sola vez
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
	LEFT JOIN dbo.clientes AS CL
	ON CL.clicod = C.ctrTitCod
	WHERE F.facNumero IS NOT NULL	--Se excluyen las prefacturas
	AND F.facEstado NOT IN (4,5)	--Se excluyen las (4) AGRUPADAS NI (5) TRASPASADAS-TR-. No es deuda 
	--AND F.facCtrCod=108600384
	AND (@NIF IS NULL OR CL.clidociden=@NIF);

	SET @sql = N'CREATE CLUSTERED INDEX IDX_' + REPLACE(CONVERT(NVARCHAR(50), NEWID()), '-', '') + ' ON #FACS(facCod, facPerCod, facCtrCod, facVersion)';
	EXEC sp_executesql @sql;	

		
	--*** DEBUG ***
	--SELECT * FROM #FACS;
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
	, F.facNumeroAqua
	, F.facEstado
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

	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#EPS]='#EPS', * FROM #EPS;
	--**************
	
	--**************
	--[30]Totalizamos los cobros por FACTURA (sin version)
	--Para calcular el estado del pago necesitamos detalles del total de los cobros asi como el último cobro 
	--#COBROS: Cobros por factura
	SELECT F.facCod 
	, F.facPerCod
	, F.facCtrCod
	, F.facVersion
	, F.facNumeroAqua
	, [efePdteCod] = CAST(NULL AS INT)
	, [efePdteScd] = CAST(NULL AS INT)
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
	INTO #COBROS
	FROM  #FACS AS F	
	INNER JOIN dbo.cobros AS CB
	ON F.RN_FAC = 1 --RN_FAC=1: Ultima vesión de la factura
	AND CB.cobCtr = F.facCtrCod	
	INNER JOIN dbo.coblin AS CBL
	ON  CB.cobScd = CBL.cblScd
	AND CB.cobPpag = CBL.cblPpag
	AND CB.cobNum = CBL.cblNum
	AND CBL.cblFacCod = F.facCod
	AND CBL.cblPer = F.facPerCod;

	--#COBROS: Cobros por efecto pendinte	
	--****************************************
	--[40]Cobros por efecto pendiente
	--#CLEP: Extraemos las lineas de cobros con sus efectos pendientes
	SELECT EP.facCod, EP.facPerCod, EP.facCtrCod, EP.facVersion, EP.efePdteCod, EP.efePdteScd, EP.facNumeroAqua
	, CLEP.*
	, EP.efePdteImporte, CL.cblImporte 
	--CN: ¿Cuantos efectos pendientes hay asociados a una misma linea de cobro?
	, CN = COUNT(clefePdteCod) OVER (PARTITION BY CLEP.cleCblScd, CLEP.cleCblPpag,  CLEP.cleCblNum,  CLEP.cleCblLin)
	--RN: Ordenación para cada efecto pendiente asociado al mismo cobro
	, RN = ROW_NUMBER() OVER (PARTITION BY CLEP.cleCblScd, CLEP.cleCblPpag, CLEP.cleCblNum,  CLEP.cleCblLin ORDER BY EP.efePdteFecVencimiento, EP.efePdteCod)
	--SUM: Totalización de los efectos pendientes asociados a un mismo cobro
	, SUMA = SUM(EP.efePdteImporte) OVER (PARTITION BY CLEP.cleCblScd, CLEP.cleCblPpag,  CLEP.cleCblNum,  CLEP.cleCblLin)
	--ACUMULADO: Total acumulado	
	, ACUMULADO = SUM(EP.efePdteImporte) OVER (PARTITION BY CLEP.cleCblScd, CLEP.cleCblPpag,  CLEP.cleCblNum,  CLEP.cleCblLin 
												   ORDER BY EP.efePdteFecVencimiento, EP.efePdteCod
												   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	
	--REPARTIR = Importe que nos queda para repartir
	, REPARTIR = CAST(0 AS MONEY)
	--IMPORTE: Desdoblamiento de la linea de cobro por efecto pendiente
	, IMPORTE  = CAST(0 AS MONEY)
	INTO #CLEP
	FROM #EPS AS EP
	INNER JOIN dbo.cobLinEfectosPendientes AS CLEP
	ON CLEP.clefePdteCod = EP.efePdteCod
	AND CLEP.clefePdteCtrCod = EP.facCtrCod
	AND CLEP.clefePdtePerCod = EP.facPerCod
	AND CLEP.clefePdteFacCod = EP.facCod
	AND CLEP.cleCblScd = EP.efePdteScd
	INNER JOIN dbo.coblin AS CL
	ON CL.cblPpag = CLEP.cleCblPpag
	AND CL.cblScd = CLEP.cleCblScd
	AND CL.cblNum = CLEP.cleCblNum
	AND CL.cblLin = CLEP.cleCblLin;

	--****************************************
	--[41]Asignamos el importe que queda por repartir a cada linea de efecto pendiente
	UPDATE C
	SET REPARTIR =  C.cblImporte-(C.Acumulado-C.efePdteImporte)
	FROM #CLEP AS C

	--****************************************
	--[42]Asignamos el total de cobro que corresponde a cada efecto pendiente
	--Si una linea de cobro se usa para cobrar un único efecto pendiente
	--o el total de los efectos pendientes asociados totalizan lo mismo que la linea de cobro
	--lo insertamos directamente como un cobro de un efecto pendiente	
	UPDATE CL SET 
	IMPORTE = CASE --Un cobro por EP, el importe es lo que diga el cobro 
				WHEN CN= 1 THEN CL.cblImporte 
				--La suma de los EP asociados es igual al total del cobro, el importe es el del EP
				WHEN SUMA = CL.cblImporte THEN CL.efePdteImporte 
				--La sumatoria no es igual al total cobrado aplicamos una reparticion del cobro entre los efectos
				WHEN REPARTIR <=0 THEN 0 --No queda nada que podamos repartir en este efecto
				WHEN RN<CN AND REPARTIR>CL.efePdteImporte THEN efePdteImporte --Cubrimos el efecto	
				WHEN RN<CN AND REPARTIR<CL.efePdteImporte THEN REPARTIR --Cubrimos con lo que nos queda para repartir
				ELSE REPARTIR END --Es la ultima linea, le dejamos todo lo que nos queda
	FROM #CLEP AS CL;
	
	
	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#CLEP]='#CLEP', * FROM #CLEP;
	--**************
	
	--[43]Insertamos los cobros por efecto pendiente
	INSERT INTO #COBROS
	SELECT CL.facCod 
	, CL.facPerCod
	, CL.facCtrCod
	, CL.facVersion
	, CL.facNumeroAqua
	, CL.efePdteCod
	, CL.efePdteScd
	, C.cobScd
	, C.cobPpag
	, C.cobNum
	, C.cobMpc
	, C.cobFec
	, C.cobOrigen
	, CL.cleCblLin
	, CL.IMPORTE
	--CN_COB: Número de cobros de compensación por efecto pendiente
	, CN_COB_COMP = SUM(IIF(C.cobMpc=@COMPENSACION, 1, 0)) OVER (PARTITION BY CL.facCod , CL.facPerCod, CL.facCtrCod, CL.facVersion, CL.efePdteCod)
	--CN_COB: Número de cobros por factura
	, CN_COB = COUNT(C.cobNum) OVER (PARTITION BY CL.facCod , CL.facPerCod, CL.facCtrCod, CL.facVersion, CL.efePdteCod)
	--RN_COB=1: Cobro mas reciente
	, RN_COB = ROW_NUMBER() OVER (PARTITION BY CL.facCod , CL.facPerCod, CL.facCtrCod, CL.facVersion, CL.efePdteCod ORDER BY C.cobFec DESC, C.cobfecReg DESC)
	--TOTAL_COB: Total cobrado por factura
	, TOTAL_COB = SUM(CL.IMPORTE) OVER (PARTITION BY CL.facCod , CL.facPerCod, CL.facCtrCod, CL.facVersion, CL.efePdteCod)
	FROM #CLEP AS CL
	INNER JOIN dbo.cobros AS C
	ON C.cobScd = CL.cleCblScd
	AND C.cobPpag = CL.cleCblPpag
	AND C.cobNum = CL.cleCblNum;
	
	
	--[51] Estado: Facturas
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
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) = F.facTotal THEN 'CO'
	--CD: Cobro detenido/Facturas con facEstado = 6
	WHEN (F.facEstado = 6) THEN 'CD'
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
	LEFT JOIN #COBROS AS C
	ON F.RN_FAC=1  --Ultima version de la factura
	AND C.RN_COB=1 --Ultimo cobro de esta factura
	AND C.efePdteCod IS NULL
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
	
	--[52] Estado: Efectos Pendientes
	--#EDO_EPS
	SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, EF.facNumeroAqua
	, F.clidociden
	, F.ctrTitDocIden
	, F.ctrTitNom
	, F.ctrTitCod
	, F.efePdteImporte
	, F.efePdteCod
	, F.efePdteFecVencimiento
	, C.TOTAL_COB	--Total cobrado por efecto pendiente
	, C.CN_COB		--Numero de cobros por efecto pendiente
	--********************
	--FACTURA ESTADO PAGO
	--********************
	, [cobEstado] = CASE 
	--PD: Si el importe cobrado supera el importe total del efecto pendiente (Pendiente devolución)
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) > F.efePdteImporte  THEN 'PD' 
	--CO: Cobrado/ factura cobrada
	WHEN ROUND(ISNULL(C.TOTAL_COB, 0), 2) = F.efePdteImporte THEN 'CO'	
	--CD: Cobro detenido/Facturas con facEstado = 6
	WHEN (F.facEstado = 6) THEN 'CD'
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
	LEFT JOIN #COBROS AS C
	ON  C.RN_COB=1 --Ultimo cobro por efecto pendiente
	AND F.efePdteCod = C.efePdteCod
	AND F.facCod = C.facCod
	AND F.facPerCod = C.facPerCod
	AND F.facCtrCod = C.facCtrCod
	AND F.efePdteCod = C.efePdteCod;
	
	--*** DEBUG ****
	IF(@NIF IS NOT NULL)
	SELECT [#EDO_EPS]='#EDO_EPS', * FROM #EDO_EPS;
	--**************
	
	--[60]#RECIBOS
	--Efectos Pendientes
	SELECT EP.facCod, EP.facPerCod, EP.facCtrCod, EP.facVersion
	, EP.facNumeroAqua
	, EP.clidociden
	, EP.ctrTitDocIden
	, EP.ctrTitNom
	, EP.ctrTitCod
	, EP.cobEstado
	, ImporteRecibo= EP.efePdteImporte
	, Cobrado=ISNULL(EP.TOTAL_COB, 0)
	, EP.efePdteCod
	, DeudaRecibo=EP.efePdteImporte-ISNULL(EP.TOTAL_COB, 0)
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
	, efePdteCod = -1
	, DeudaRecibo=F.facTotal-ISNULL(F.TOTAL_COB, 0)
	, [Fecha] = F.facFecha
	FROM #EDO_FAC AS F
	WHERE F.cobEstado NOT IN('CO', 'TR', 'CM', 'FR');

	
	--Facturas y Efectos Pendientes
	WITH T AS(
	SELECT [NIF] = R.ctrTitDocIden
	, [Nombre] = R.ctrTitNom
	, [Factura] = R.facNumeroAqua
	, [Cod_EfectoPdte] = IIF(R.efePdteCod IS NULL OR R.efePdteCod<=0, NULL, R.efePdteCod)
	, [Fecha Factura] = CAST(R.Fecha AS DATE)
	, [Estado] = R.cobEstado
	, [Importe RECIBO] = R.ImporteRecibo
	, [Importe PAGO] = R.DeudaRecibo*IIF(cobEstado IS NOT NULL AND cobEstado='PD', 0, 1)
	, [Importe DEVOLUCION] =  R.DeudaRecibo* IIF(cobEstado IS NOT NULL AND cobEstado='PD', -1, 0)
	, [Importe Deuda] = R.DeudaRecibo * IIF(cobEstado IS NOT NULL AND cobEstado='PD', -1, 1)
	FROM #RECIBOS AS R
	WHERE (@NIF IS NULL OR  R.clidociden=@NIF)
	
	--Entregas a cuenta
	UNION ALL
	SELECT E.NIF 
	, E.Nombre COLLATE Modern_Spanish_CI_AS
	, [Factura] = NULL
	, [Cod_EfectoPdte] = NULL
	, E.[Fecha Factura]
	, [Estado] = 'PD'
	, [Importe RECIBO] = NULL
	, [Importe PAGO] = 0
	, [Importe DEVOLUCION] = E.[Importe DEUDA]
	, [Importe Deuda] = E.[Importe DEUDA]*-1
	FROM #ECxDEUDA AS E
	WHERE  (@NIF IS NULL OR E.NIF=@NIF))

	SELECT * FROM T
	ORDER BY [NIF], [Nombre], [Factura], [Cod_EfectoPdte];
	
	END TRY
	
	BEGIN CATCH
		SELECT  @p_errId_out = ERROR_NUMBER()
			 ,  @p_errMsg_out= ERROR_MESSAGE();
	END CATCH

	DROP TABLE IF EXISTS  #FACTOTALES;
	DROP TABLE IF EXISTS  #FACS;
	DROP TABLE IF EXISTS  #EDO_FAC;
	DROP TABLE IF EXISTS  #EDO_EPS;

	DROP TABLE IF EXISTS  #COBROS;
	DROP TABLE IF EXISTS  #EPS;
	DROP TABLE IF EXISTS  #CLEP;
	DROP TABLE IF EXISTS  #RECIBOS;
	DROP TABLE IF EXISTS  #ECxDEUDA;

GO

