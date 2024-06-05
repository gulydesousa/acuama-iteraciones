/*
DELETE FROM otInspeccionesNotificacionEmisiones_Melilla
DELETE FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
DELETE FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones


SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones
SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
SELECT * FROM dbo.otInspeccionesNotificacionEmisiones_Melilla 
SELECT * 
--DELETE
FROM task_Schedule WHERE tskuser='gmdesousa'
*/
--PRUEBA CON_ANOMALIA: 10026
--PRUEBA SIN ANOMALIA: 16258-16764
-- Tipo Incidencia: Lectura, Inspeccion
-- OT con anomalía(apto = false)
-- OT sin anomalía (apto = true)
/*
DECLARE	
	@tipo VARCHAR(20)='OT con anomalía',
	@excluirNoEmision BIT = 0,
	@contratoD INT = NULL,
	@contratoH INT = NULL,
	@zonaD VARCHAR(4) = NULL,
	@zonaH VARCHAR(4) = NULL,
	--Se filtra por la ruta en las inspecciones
	@ruta1D VARCHAR(10) = NULL,
	@ruta1H VARCHAR(10) = NULL,
	@ruta2D VARCHAR(10) = NULL,
	@ruta2H VARCHAR(10) = NULL,
	@ruta3D VARCHAR(10) = NULL,
	@ruta3H VARCHAR(10) = NULL,
	@ruta4D VARCHAR(10) = NULL,
	@ruta4H VARCHAR(10) = NULL,
	@ruta5D VARCHAR(10) = NULL,
	@ruta5H VARCHAR(10) = NULL,
	@ruta6D VARCHAR(10) = NULL,
	@ruta6H VARCHAR(10) = NULL,
-- Si es un listado: En este SP no hacemos nada en particular.
	@listado BIT = NULL,		 
-- Representante legal(Si, No, Indiferente) | Si tiene representante legal debe sacar dos cartas
	@legal VARCHAR(20) = NULL,	 
	@tieneEmail BIT = NULL,		
-- BATERIAS, CONTADORES
	@servicio VARCHAR(25) = NULL, 
-- Orden para los registros
	@orden VARCHAR(20) = NULL	  	
-- ******************************************
-- Si envias un id de emision, se van a traer los datos de la tabla de emisiones 
	, @idEmision INT = 0

	EXEC [ReportingServices].[TO039_Inspecciones_Melilla] @tipo, @excluirNoEmision, @contratoD, @contratoH, @zonaD, @zonaH 
	, @ruta1D, @ruta1H, @ruta2D, @ruta2H, @ruta3D, @ruta3H, @ruta4D, @ruta4H, @ruta5D, @ruta5H, @ruta6D, @ruta6H
	, @listado, @legal, @tieneEmail, @servicio, @orden, @idEmision;

*/
CREATE PROCEDURE [ReportingServices].[TO039_Inspecciones_Melilla]
-- Tipo Incidencia: Lectura, Inspeccion
-- OT con anomalía(apto = false)
-- OT sin anomalía (apto = true)
	@tipo VARCHAR(20)='OT sin anomalía',
	@excluirNoEmision BIT = 0,
	@contratoD INT = NULL,
	@contratoH INT = NULL,
	@zonaD VARCHAR(4) = NULL,
	@zonaH VARCHAR(4) = NULL,
	--Se filtra por la ruta en las inspecciones
	@ruta1D VARCHAR(10) = NULL,
	@ruta1H VARCHAR(10) = NULL,
	@ruta2D VARCHAR(10) = NULL,
	@ruta2H VARCHAR(10) = NULL,
	@ruta3D VARCHAR(10) = NULL,
	@ruta3H VARCHAR(10) = NULL,
	@ruta4D VARCHAR(10) = NULL,
	@ruta4H VARCHAR(10) = NULL,
	@ruta5D VARCHAR(10) = NULL,
	@ruta5H VARCHAR(10) = NULL,
	@ruta6D VARCHAR(10) = NULL,
	@ruta6H VARCHAR(10) = NULL,
-- Si es un listado: En este SP no hacemos nada en particular.
	@listado BIT = NULL,		 
-- Representante legal(Si, No, Indiferente) | Si tiene representante legal debe sacar dos cartas
	@legal VARCHAR(20) = NULL,	 
	@tieneEmail BIT = NULL,		
-- BATERIAS, CONTADORES
	@servicio VARCHAR(25) = NULL, 
-- Orden para los registros
	@orden VARCHAR(20) = NULL	  	
-- ******************************************
-- Si envias un id de emision, se van a traer los datos de la tabla de emisiones 
	, @idEmision INT = 0
AS

SET NOCOUNT ON;
BEGIN TRY	

	-- ******************************************
	-- [00] Tipo de ejecución
	--		La emisión se ha hecho en un paso previo
	--		Solo necesitamos traer los datos en el orden correcto
	--		Retorna el id de la emisión y los datos
	-- ******************************************
	IF(@idEmision IS NOT NULL AND @idEmision>0)
	BEGIN
		SELECT * 
		FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
		WHERE N.emisionID = @idEmision
		ORDER BY RN;

		RETURN;
	END
	

	BEGIN TRANSACTION;
	-- ******************************************
	-- [01] Variables
	-- ******************************************
	--Para sacar las inspecciones con los filtros de la pantalla de "Emisión de Notificaciones"
	SELECT @excluirNoEmision = ISNULL(@excluirNoEmision, 1); --Por defecto siempre se excluyen los que tienen No-Emisión
	
	DECLARE @apto BIT = CASE  @tipo WHEN 'OT con anomalía' THEN 0
									WHEN 'OT sin anomalía' THEN 1
									ELSE NULL END;

	DECLARE @spName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
	
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	--Hace falta esta temporal, que sino va muy lento
	CREATE TABLE #CONTADORES(
    ctrcod INT PRIMARY KEY,
    conNumSerie VARCHAR(25),
    conDiametro SMALLINT,
    conID INT);
	
	-- ******************************************
	-- [02] Contadores Instalados
	-- ******************************************		
	INSERT INTO #CONTADORES
    SELECT DISTINCT V.ctrCod, V.conNumSerie, V.conDiametro, V.conId
    FROM vCambiosContador AS V
        LEFT JOIN dbo.otInspecciones_Melilla AS I
        ON I.ctrcod = V.ctrCod
    WHERE V.esUltimaInstalacion = 1 AND V.opRetirada IS NULL;	
	

	-- ******************************************
	-- [03] Servicio Agua
	-- ******************************************		
	SELECT S.ctsctrcod, S.ctssrv, S.ctstar, S.ctsuds, S.ctslin, T.trfdes
	--RN=1 para quedarnos con una sola linea por agua
	, RN = ROW_NUMBER() OVER (PARTITION BY  S.ctsctrcod ORDER BY S.ctslin ASC)
	, CN = COUNT(S.ctslin) OVER (PARTITION BY  S.ctsctrcod)
    INTO #AGUA
    FROM dbo.ContratoServicio AS S
        INNER JOIN dbo.tarifas AS T
        ON  T.trfsrvcod = S.ctssrv
            AND T.trfcod = S.ctstar
    WHERE S.ctssrv=1 AND S.ctsfecbaj IS NULL;
	
	-- ******************************************
	-- [04.1] #RESULT: Datos para el "Titulares"
	-- ******************************************
	SELECT  V.objectid, V.Servicio	
	, [REGISTROENTREGA] = V.objectid
	, [CONTRATO] = V.ctrcod 
	, [USUARIOCOD] = CC.ctrTitCod
	, [INMUEBLECOD] = CC.ctrinmcod
	, [CALIBRE] = CCC.conDiametro
	, [INMUEBLECODPOSTAL] = II.inmcpost --CPostal
	, [MARCACONTADOR] = MA.mcndes
	, [REFCATASTRAL] = II.inmrefcatastral
	, [FISNOM] = CC.ctrTitNom	--NombreTitular
	, [BLOQUE] = V.zonCod
	, [RUTA] = FORMATMESSAGE('%05d.%05d.%05d.%05d.%05d.%05d'
			 , IIF(ISNUMERIC(I.ruta1)=1, CAST(I.ruta1 AS INT), 0)						
			 , IIF(ISNUMERIC(I.ruta2)=1, CAST(I.ruta2 AS INT), 0)
			 , IIF(ISNUMERIC(I.ruta3)=1, CAST(I.ruta3 AS INT), 0)
			 , IIF(ISNUMERIC(I.ruta4)=1, CAST(I.ruta4 AS INT), 0)						
			 , IIF(ISNUMERIC(I.ruta5)=1, CAST(I.ruta5 AS INT), 0)
			 , IIF(ISNUMERIC(I.ruta6)=1, CAST(I.ruta6 AS INT), 0))


	, [ORDEN] = FORMATMESSAGE('%05d.%05d.%05d.%05d.%05d.%05d'
			 , IIF(ISNUMERIC(I.ruta1)=1, CAST(I.ruta1 AS INT), 0)						
			 , IIF(ISNUMERIC(I.ruta2)=1, CAST(I.ruta2 AS INT), 0)
			 , IIF(ISNUMERIC(I.ruta3)=1, CAST(I.ruta3 AS INT), 0)
			 , IIF(ISNUMERIC(I.ruta4)=1, CAST(I.ruta4 AS INT), 0)						
			 , IIF(ISNUMERIC(I.ruta5)=1, CAST(I.ruta5 AS INT), 0)
			 , IIF(ISNUMERIC(I.ruta6)=1, CAST(I.ruta6 AS INT), 0))
	
	, [FISNIF] = CC.ctrTitDocIden --NifTitular
	--, [FISDIR1]  = CC.ctrTitDir
	, [FISDIR1]  = II.inmDireccion --Dirección Titulares: Debe tomarse de la dirección del inmueble sobre el que se hace la notificación.
	, [TITULARCPOSTAL] = CC.ctrTitCPos
	, [FISDIR2] = CC.ctrEnvDir
	, [ENVIOCPOSTAL] = CC.ctrEnvCPos
	, [FISTEL] = CC.ctrTlf1			--FISTEL1
	, [FISTEL2] = CC.ctrTlf2
	, [MAILDATOS] = CC.ctrEmail
	, [CONTADOR] = CCC.conNumSerie	--conNumSerie
	, [TRIMESTRE] = ISNULL(CONVERT(NVARCHAR, CC.ctrfecini, 103), '') 
	, [DOTACIONES] = A.ctsuds
	, [TARIFA] = A.ctstar
	, [NOMTARIFA] = A.trfdes
	, [CONTRATOCOMUNITARIO] = CC.ctrComunitario
	, [REPRESENTANTE] = CC.ctrRepresent
	--, CL.clinom
	, [CLI_REPRESENTANTE] = CC.ctrValorc4
	--Otros Campos:
	, CC.ctrTlfRef1
	, CC.ctrTlfRef2
	, CC.ctrTlfRef3
	, CC.ctrTlf3
	--Inmueble
	, [INMUEBLE]  = II.inmDireccion 
	, [Calle] = II.inmcalle
	, [Piso] = II.inmplanta
	, [Puerta] = II.inmpuerta
	, [Numero] = II.inmfinca
	, [Portal] = II.inmentrada
	, [ZONA] = V.zona
	--DatosOT
	, [otApta] = V.Apta
	, [otSociedad] = I.otiserscd
	, [otSerie] = I.otisercod
	, [otNum] = I.otinum
	, [otFecReg] = ot.otFechaReg --FechaOT
	--ORDER BY
	, [SujetoPasivo] = UPPER(RTRIM(LTRIM(ISNULL(CC.ctrRepresent, CC.ctrTitNom))))
	, V.emisionEstado
	, RN = CAST(NULL AS INT)
    INTO #RESULT
	--Usamos V porque en esta vista estan las inspecciones originales solamente: vOtInspeccionesNotificacionEmisiones_Melilla
	-- votInspecciones_Melilla tiene los padres e hijos
    FROM vOtInspeccionesNotificacionEmisiones_Melilla  AS V 
        INNER JOIN dbo.otInspecciones_Melilla AS I
        ON V.objectid = I.objectID
		AND V.MOCK = 0 --#89320: BUG-Cartas con notificación a contratos padres no incluidos en la inspección
		--Solo si se pueden emitir
		AND V.emisionEstado='Emitir'
        LEFT JOIN dbo.vContratosUltimaVersion AS C
        ON V.ctrcod = C.ctrCod
        LEFT JOIN dbo.Contratos AS CC
        ON CC.ctrcod = C.ctrCod AND CC.ctrversion= C.ctrVersion
        LEFT JOIN inmuebles AS II
        ON II.inmcod = C.ctrinmcod
        LEFT JOIN #CONTADORES AS CCC
        ON CCC.ctrCod = CC.ctrCod
        LEFT JOIN dbo.contador AS CO
        ON CO.conID = CCC.conID
        LEFT JOIN dbo.marcon AS MA
        ON MA.mcncod = CO.conMcnCod
        LEFT JOIN #AGUA AS A
        ON A.ctsctrcod = CC.ctrcod
        LEFT JOIN [dbo].[vEmailNotificaciones] AS E
        ON E.[contrato.ctrCod] = C.ctrCod
            AND E.[contrato.ctrVersion] = C.ctrVersion
        LEFT JOIN ordenTrabajo AS OT
        ON OT.otserscd = I.otiserscd
            AND OT.otsercod = I.otisercod
            AND OT.otnum = I.otinum
        LEFT JOIN dbo.clientes AS CL
        ON CL.clicod = CAST(CC.ctrValorc4 AS INT)
    
    WHERE  (@excluirNoEmision=0 OR (@excluirNoEmision=1 AND (CC.ctrNoEmision IS NULL OR CC.ctrNoEmision=0)))
        AND (@contratoD IS NULL OR V.ctrcod>=@contratoD)
        AND (@contratoH IS NULL OR V.ctrcod<=@contratoH)
        AND (@zonaD IS NULL OR @zonaD ='' OR V.zonCod>=@zonaD)
        AND (@zonaH IS NULL OR @zonaH ='' OR V.zonCod<=@zonaH)
        ----**************************************
        AND (@ruta1D IS NULL OR ISNUMERIC(@ruta1D)=0 OR (ISNUMERIC(@ruta1D)=1 AND I.ruta1 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta1)=1 THEN I.ruta1 ELSE '0' END AS INT)>=CASE WHEN ISNUMERIC(@ruta1D)=1 THEN CAST(@ruta1D AS INT) ELSE NULL END))
        AND (@ruta1H IS NULL OR ISNUMERIC(@ruta1H)=0 OR (ISNUMERIC(@ruta1H)=1 AND I.ruta1 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta1)=1 THEN I.ruta1 ELSE '0' END AS INT)<=CASE WHEN ISNUMERIC(@ruta1H)=1 THEN CAST(@ruta1H AS INT) ELSE NULL END))

        AND (@ruta2D IS NULL OR ISNUMERIC(@ruta2D)=0 OR (ISNUMERIC(@ruta2D)=1 AND I.ruta2 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta2)=1 THEN I.ruta2 ELSE '0' END AS INT)>=CASE WHEN ISNUMERIC(@ruta2D)=1 THEN CAST(@ruta2D AS INT) ELSE NULL END))
        AND (@ruta2H IS NULL OR ISNUMERIC(@ruta2H)=0 OR (ISNUMERIC(@ruta2H)=1 AND I.ruta2 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta2)=1 THEN I.ruta2 ELSE '0' END AS INT)<=CASE WHEN ISNUMERIC(@ruta2H)=1 THEN CAST(@ruta2H AS INT) ELSE NULL END))

        AND (@ruta3D IS NULL OR ISNUMERIC(@ruta3D)=0 OR (ISNUMERIC(@ruta3D)=1 AND I.ruta3 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta3)=1 THEN I.ruta3 ELSE '0' END AS INT)>=CASE WHEN ISNUMERIC(@ruta3D)=1 THEN CAST(@ruta3D AS INT) ELSE NULL END))
        AND (@ruta3H IS NULL OR ISNUMERIC(@ruta3H)=0 OR (ISNUMERIC(@ruta3H)=1 AND I.ruta3 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta3)=1 THEN I.ruta3 ELSE '0' END AS INT)<=CASE WHEN ISNUMERIC(@ruta3H)=1 THEN CAST(@ruta3H AS INT) ELSE NULL END))

        AND (@ruta4D IS NULL OR ISNUMERIC(@ruta4D)=0 OR (ISNUMERIC(@ruta4D)=1 AND I.ruta4 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta4)=1 THEN I.ruta4 ELSE '0' END AS INT)>=CASE WHEN ISNUMERIC(@ruta4D)=1 THEN CAST(@ruta4D AS INT) ELSE NULL END))
        AND (@ruta4H IS NULL OR ISNUMERIC(@ruta4H)=0 OR (ISNUMERIC(@ruta4H)=1 AND I.ruta4 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta4)=1 THEN I.ruta4 ELSE '0' END AS INT)<=CASE WHEN ISNUMERIC(@ruta4H)=1 THEN CAST(@ruta4H AS INT) ELSE NULL END))

        AND (@ruta5D IS NULL OR ISNUMERIC(@ruta5D)=0 OR (ISNUMERIC(@ruta5D)=1 AND I.ruta5 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta5)=1 THEN I.ruta5 ELSE '0' END AS INT)>=CASE WHEN ISNUMERIC(@ruta5D)=1 THEN CAST(@ruta5D AS INT) ELSE NULL END))
        AND (@ruta5H IS NULL OR ISNUMERIC(@ruta5H)=0 OR (ISNUMERIC(@ruta5H)=1 AND I.ruta5 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta5)=1 THEN I.ruta5 ELSE '0' END AS INT)<=CASE WHEN ISNUMERIC(@ruta5H)=1 THEN CAST(@ruta5H AS INT) ELSE NULL END))

        AND (@ruta6D IS NULL OR ISNUMERIC(@ruta6D)=0 OR (ISNUMERIC(@ruta6D)=1 AND I.ruta6 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta6)=1 THEN I.ruta6 ELSE '0' END AS INT)>=CASE WHEN ISNUMERIC(@ruta6D)=1 THEN CAST(@ruta6D AS INT) ELSE NULL END))
        AND (@ruta6H IS NULL OR ISNUMERIC(@ruta6H)=0 OR (ISNUMERIC(@ruta6H)=1 AND I.ruta6 IS NOT NULL AND CAST(CASE WHEN ISNUMERIC(I.ruta6)=1 THEN I.ruta6 ELSE '0' END AS INT)<=CASE WHEN ISNUMERIC(@ruta6H)=1 THEN CAST(@ruta6H AS INT) ELSE NULL END))

        AND (@legal IS NULL OR @legal = 'Indiferente' OR (@legal='Si' AND CC.ctrRepresent IS NOT NULL AND CC.ctrRepresent<>'') OR (@legal='No' AND (CC.ctrRepresent IS NULL OR CC.ctrRepresent='')))
        AND (@tieneEmail IS NULL OR (@tieneEmail = 1 AND E.[emailTo*] IS NOT NULL AND LEN(E.[emailTo*]) > 0) OR (@tieneEmail = 0 AND (E.[emailTo*] IS NULL OR LEN(E.[emailTo*]) = 0)))
        AND (@servicio IS NULL OR @servicio='' OR I.servicio = @servicio)
        AND (@apto IS NULL OR (@apto=1 AND V.Apta IN ('APTO 100%')) OR (@apto=0 AND V.Apta IN ('SI', 'NO')));	


	-- ******************************************
	-- [04.2] #RESULT: Datos para "Representantes" de los contratos generales
	-- ******************************************
	INSERT INTO #RESULT
    SELECT objectid, Servicio	
        , [REGISTROENTREGA]
        --WordTemplate_Contratos: OnFieldValueRequest
        , [CONTRATO] 
        , [USUARIOCOD] = C.clicod
        , [INMUEBLECOD] 
        , [CALIBRE]
        , [INMUEBLECODPOSTAL] 
        , [MARCACONTADOR]
        , [REFCATASTRAL] 
        , [FISNOM] = C.clinom
        , [BLOQUE]
        , [RUTA] 
        , [ORDEN]
        , [FISNIF] = C.clidociden
        , [FISDIR1]  = C.clidomicilio --Dirección Representante: Tomarla de los datos de la tabla cliente.
		--, [FISDIR1]
        , [TITULARCPOSTAL] = C.clicpostal
        , [FISDIR2] 
        , [ENVIOCPOSTAL] 
        , [FISTEL] = C.clitelefono1
        , [FISTEL2] = C.clitelefono2
        , [MAILDATOS] = C.climail
        , [CONTADOR] 
        , [TRIMESTRE]
        , [DOTACIONES]
        , [TARIFA] 
        , [NOMTARIFA] 
        , [CONTRATOCOMUNITARIO] 
        , [REPRESENTANTE]
        --, CL.clinom
        , [CLI_REPRESENTANTE] 
        --Otros Campos:
        , ctrTlfRef1 = C.clireftelf1
        , ctrTlfRef2
        , ctrTlfRef3
        , ctrTlf3
        --Inmueble
        , [INMUEBLE] 
        , [Calle] 
        , [Piso] 
        , [Puerta] 
        , [Numero] 
        , [Portal] 
        , [ZONA] 
        --DatosOT
        , [otApta] 
        , [otSociedad] 
        , [otSerie] 
        , [otNum] 
        , [otFecReg] 
        --ORDER BY
        , [SujetoPasivo] 
		, [emisionEstado] = [emisionEstado] + ' para Representante'
		, RN = CAST(NULL AS INT)
    FROM #RESULT AS R
    INNER JOIN dbo.clientes AS C
    ON CLI_REPRESENTANTE IS NOT NULL
        AND C.clicod = R.CLI_REPRESENTANTE;
	
	--*****************************************
	--[05] #RESULT.RN: Insertamos el orden a los resultados
	--	  Necesarios para la pegatina
	--*****************************************
	WITH CTE AS(
	 SELECT RN, ROW_NUMBER() OVER (ORDER BY 
		  IIF(@orden='ruta', [RUTA], '')
        , IIF(@orden='ruta', [ORDEN], '')
        , IIF(@orden='suministro', [FISDIR1], '')
        , IIF(@orden='sujeto pasivo', [SujetoPasivo], '')
        , IIF(@orden='doc.iden', [FISNIF], '')
        , IIF(@orden='Representante',  UPPER([REPRESENTANTE]), '')
        , contrato, objectid, [emisionEstado]) AS NewRN
		FROM #RESULT
	)
	UPDATE CTE SET RN = NewRN;


	--*****************************************
	--[99] Finalizamos trayendo los datos
	--*****************************************
	SELECT *
	, emisionID = ISNULL(@idEmision, 0) 
	FROM #RESULT ORDER BY RN;	
    
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    --ROLLBACK TRANSACTION si hay un error
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
		SET @idEmision = -1;
        THROW;
    END 
END CATCH

IF OBJECT_ID('tempdb..#CONTADORES') IS NOT NULL DROP TABLE #CONTADORES;
IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL DROP TABLE #RESULT;
IF OBJECT_ID('tempdb..#AGUA') IS NOT NULL DROP TABLE #AGUA;

GO


