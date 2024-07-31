DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_error_out INT;
DECLARE @p_errMsg_out   NVARCHAR(MAX);

SET @p_params= '<NodoXML><LI><tipoOts>INSEDC</tipoOts></LI></NodoXML>'


/*

CREATE PROCEDURE [InformesExcel].[InformeOTsRealizadas]
	@p_params NVARCHAR(MAX),
	@p_errId_out INT OUTPUT, 
	@p_errMsg_out NVARCHAR(2048) OUTPUT
AS
*/
	
	--**********
	--PARAMETROS: 
	--N/A
	--**********

	SET NOCOUNT ON;   
	BEGIN TRY
	
	--********************
	--INICIO: 2 DataTables
	-- 1: Parametros del encabezado: N/A
	-- 2: Datos
	--********************

	--DataTable[1]:  Parametros
	DECLARE @xml AS XML = @p_params;
	DECLARE @params TABLE (	FecRegDesde DATETIME NULL,
							FecRegHasta DATETIME NULL,
							FecResDesde DATETIME NULL,
							FecResHasta DATETIME NULL,
							FecDevDesde DATETIME NULL,
							FecDevHasta DATETIME NULL,
							tipoOts VARCHAR(10) null, 
							soloPendientes BIT);

	INSERT INTO @params
	SELECT  FecRegDesde = CASE WHEN M.Item.value('FecRegDesde[1]', 'DATETIME') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecRegDesde[1]', 'DATETIME') END
		  , FecRegHasta = CASE WHEN M.Item.value('FecRegHasta[1]', 'DATETIME') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecRegHasta[1]', 'DATETIME') END
		  , FecResDesde = CASE WHEN M.Item.value('FecResDesde[1]', 'DATETIME') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecResDesde[1]', 'DATETIME') END
		  , FecResHasta = CASE WHEN M.Item.value('FecResHasta[1]', 'DATETIME') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecResHasta[1]', 'DATETIME') END
		  , FecDevDesde = CASE WHEN M.Item.value('FecDevDesde[1]', 'DATETIME') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecDevDesde[1]', 'DATETIME') END
		  , FecDevHasta = CASE WHEN M.Item.value('FecDevHasta[1]', 'DATETIME') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecDevHasta[1]', 'DATETIME') END
		  , tipoOts = IIF(M.Item.value('tipoOts[1]', 'VARCHAR(20)') = '', NULL
						  , M.Item.value('tipoOts[1]', 'VARCHAR(20)'))
		  , soloPendientes = IIF(M.Item.value('soloPendientes[1]', 'BIT') = '', 0
						  , M.Item.value('soloPendientes[1]', 'BIT'))
	FROM @xml.nodes('NodoXML/LI')AS M(Item);
	
	UPDATE @params SET 
	  FecRegDesde = DATEADD(DAY, 1, FecRegDesde)
	, FecRegHasta = DATEADD(DAY, 1, FecRegHasta)
	, FecResDesde = DATEADD(DAY, 1, FecResDesde)
	, FecResHasta = DATEADD(DAY, 1, FecResHasta)
	, FecDevDesde = DATEADD(DAY, 1, FecDevDesde)
	, FecDevHasta = DATEADD(DAY, 1, FecDevHasta)
	OUTPUT DELETED.*;

	--********************
	--VALIDAR PARAMETROS
	--Fechas obligatorias

	IF EXISTS(SELECT 1 FROM @params WHERE FecRegDesde>FecRegHasta)
		THROW 50002 , 'La fecha de registro ''hasta'' debe ser posterior a la fecha de registro ''desde''.', 1;

	IF EXISTS(SELECT 1 FROM @params WHERE FecResDesde>FecResHasta)
		THROW 50002 , 'La fecha de resolución ''hasta'' debe ser posterior a la fecha de resolución ''desde''.', 1;

	IF EXISTS(SELECT 1 FROM @params WHERE FecDevDesde>FecDevHasta)
		THROW 50002 , 'La fecha de devolución ''hasta'' debe ser posterior a la fecha de devolución ''desde''.', 1;
	
	

	SELECT
	CT.otMovFecDev,
	CT.otFechaReg,
	CT.otFecResolucion,
		datename(hour,CT.otfrealizacionInicial) + ':'+ datename(minute,otfrealizacionInicial) 'Hora llegada',
		datename(hour,CT.otfrealizacion) + ':'+ datename(minute,otfrealizacion) 'Hora salida',
		cttnom AS Contratistas,
		OOT.Operario1 AS Operario1,
		OOT.Operario2 AS Operario2,
		OOT.Operario3 AS Operario3,
		OOT.Operario4 AS Operario4,
		OOT.Operario5 AS Operario5,
		CTR.ctrcod AS Contrato,
		CT.otnum AS 'Nº Ot',
		CASE 
			WHEN CT.otfcierre IS NOT NULL THEN 'Cerrada'
			WHEN CT.otFecResolucion IS NOT NULL THEN 'Resuelta'
			WHEN CT.otFecEmision IS NOT NULL THEN 'Resuelta'
			ELSE 'Creada'
		END AS 'Estado Ot',
		OTT.ottdes AS 'Tipo Ot',
		CT.otdireccion AS Direccion,
		ctrzoncod AS Zona,
		CASE 
			WHEN CC.conCamLecRet IS NOT NULL AND CC.conCamLecRet <> 0 THEN C.conNumSerie
			ELSE NULL
		END AS 'N Contador Desinstalado',
		CC.conCamLecRet AS 'Lectura retirada',
		CASE 
			WHEN CC.conCamLecIns IS NOT NULL THEN C.conNumSerie
			ELSE NULL
		END AS 'Nº Contador instalado',
		CC.conCamLecIns AS 'Lectura instalación',
		CT.otContCalibre AS Calibre,
		MC.mdlDes AS 'Modelo contador instalado',
		CT.otContNumPrecinto AS Precinto,
		C.conNumRefClipLoRa AS 'Nº Módulo EDC',
		TI.tipIncOtDesc AS 'Incidencia'
	FROM contador C 
	INNER JOIN contadorCambio CC ON C.conID = CC.conCamConID
	INNER JOIN ordenTrabajo CT ON CC.conCamOtSerScd = CT.otserscd AND CC.conCamOtSerCod = CT.otsercod AND CC.conCamOtNum = CT.otnum
	INNER JOIN contratos CTR ON CT.otCtrCod = CTR.ctrcod
	INNER JOIN contratistas CTRT ON CT.otEplCttCod = CTRT.cttcod
	INNER JOIN modcon MC ON C.conMcnCod = MC.mdlMcnCod
	INNER JOIN otIncidencias I ON CT.otnum = I.otIncotnum
	INNER JOIN tipoIncidenciaOT TI ON I.otIncTipOtCod = TI.tipIncOtCod
	INNER JOIN ottipos OTT ON CT.otottcod = OTT.ottcod
	LEFT JOIN (
		SELECT 
			OTnum,	
			MAX(CASE WHEN RowNum = 1 THEN NombreEmpleado END) AS Operario1,
			MAX(CASE WHEN RowNum = 2 THEN NombreEmpleado END) AS Operario2,
			MAX(CASE WHEN RowNum = 3 THEN NombreEmpleado END) AS Operario3,
			MAX(CASE WHEN RowNum = 4 THEN NombreEmpleado END) AS Operario4,
			MAX(CASE WHEN RowNum = 5 THEN NombreEmpleado END) AS Operario5	
		FROM(
			SELECT
				OTR.otnum AS OTnum,		
				E.eplcod,
				E.eplnom AS NombreEmpleado,
				ROW_NUMBER() OVER (PARTITION BY OTR.otnum ORDER BY E.eplcod) AS RowNum
			FROM OTempleadosRelacionados OTR
			LEFT JOIN empleados E ON OTR.eplcod = E.eplcod 
			--WHERE 
			--OTR.otnum = @otnum
		) AS OTS
		GROUP BY OTS.OTnum
	)AS OOT ON CT.otnum = OOT.OTnum
	INNER JOIN @params P ON
	(
	(P.FecRegDesde IS NULL OR CT.otFechaReg IS NULL OR (CT.otFechaReg IS NOT NULL AND CT.otFechaReg >= P.FecRegDesde)) 
	AND (P.FecRegHasta IS NULL OR CT.otFechaReg IS NULL OR (CT.otFechaReg IS NOT NULL AND CT.otFechaReg < P.FecRegHasta))
	AND (P.FecResDesde IS NULL OR CT.otFecResolucion IS NULL OR (CT.otFecResolucion IS NOT NULL AND CT.otFecResolucion >= P.FecResDesde)) 
	AND (P.FecResHasta IS NULL OR CT.otFecResolucion IS NULL OR (CT.otFecResolucion IS NOT NULL AND CT.otFecResolucion < P.FecResHasta))
	AND (P.FecDevDesde IS NULL OR CT.otMovFecDev IS NULL OR (CT.otMovFecDev IS NOT NULL AND CT.otMovFecDev >= P.FecDevDesde)) 
	AND (P.FecDevHasta IS NULL OR CT.otMovFecDev IS NULL OR (CT.otMovFecDev IS NOT NULL AND CT.otMovFecDev < P.FecDevHasta))
	AND	(P.soloPendientes = 0 OR (P.soloPendientes = 1 AND CT.otfcierre IS NULL))
	AND (P.tipoOts IS NULL OR P.tipoOts = OTT.ottcod)
	)
	
	   
	END TRY
	BEGIN CATCH
		SELECT  @p_errId_out = ERROR_NUMBER()
			 ,  @p_errMsg_out= ERROR_MESSAGE();

			 
	END CATCH
GO


