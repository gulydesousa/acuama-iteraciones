/************************************
DECLARE @mes INT = 1;
DECLARE @anyo INT = 2023;
DECLARE @tipo INT = 1;

EXEC [dbo].[InformeFacturasSiiPendientes] @mes, @anyo, @tipo
***********************************/
ALTER PROCEDURE [dbo].[InformeFacturasSiiPendientes]	
     @mes INT = NULL
    ,@anyo INT = NULL
	,@tipo INT -- tipo 1 por mes año /tipo 2 todas las pendientes
AS
BEGIN TRY

	IF (@tipo = 1) 
	BEGIN	
		--*****************************
		--#TIPO1: @tipo=1
		SELECT [fechaFactura] = CONVERT(VARCHAR(10), fechaFactura, 103)
		, serDesc
		, fcSiiNumSerieFacturaEmisor
		, fcSiiContraparteNombreRazon
		, docIden
		, info
		--*****************************
		, [baseImponible] = ISNULL(CASE WHEN fcSiiTipoFactura = 'AN' 
							THEN (SELECT SUM(fclSiiBaseImponible)                        
									FROM dbo.vFacturasSiiBaseIvaAnuladas AS V
									WHERE V.fclSiiFacCtrCod = T.fcSiiFacCtrCod
									  AND V.fclSiiFacPerCod = T.fcSiiFacPerCod
									  AND V.fclSiiFacCod = T.fcSiiFacCod
									  AND V.fclSiiFacVersion = T.fcSiiFacVersion
									  AND V.fclSiiNumEnvio = T.fcSiiNumEnvio)
							ELSE (SELECT SUM(fclSiiBaseImponible)
									FROM dbo.vFacturasSiiBaseIvaNoAnuladas AS V
									WHERE V.fclSiiFacCtrCod = T.fcSiiFacCtrCod
									  AND V.fclSiiFacPerCod = T.fcSiiFacPerCod
									  AND V.fclSiiFacCod = T.fcSiiFacCod
									  AND V.fclSiiFacVersion = T.fcSiiFacVersion
									  AND V.fclSiiNumEnvio = T.fcSiiNumEnvio)
							END, 0)     
		--*****************************
		,[cuotaRepercutida] = ISNULL(CASE WHEN fcSiiTipoFactura = 'AN' 
							  THEN (SELECT SUM(fclSiiCuotaRepercutida)                        
										FROM dbo.vFacturasSiiBaseIvaAnuladas AS V
										WHERE V.fclSiiFacCtrCod = T.fcSiiFacCtrCod
										  AND V.fclSiiFacPerCod = T.fcSiiFacPerCod
										  AND V.fclSiiFacCod = T.fcSiiFacCod
										  AND V.fclSiiFacVersion = T.fcSiiFacVersion
										  AND V.fclSiiNumEnvio = T.fcSiiNumEnvio)    
							  ELSE (SELECT SUM(fclSiiCuotaRepercutida)                        
									  FROM dbo.vFacturasSiiBaseIvaNoAnuladas AS V
									  WHERE V.fclSiiFacCtrCod = T.fcSiiFacCtrCod
										AND V.fclSiiFacPerCod = T.fcSiiFacPerCod
										AND V.fclSiiFacCod = T.fcSiiFacCod
										AND V.fclSiiFacVersion = T.fcSiiFacVersion
										AND V.fclSiiNumEnvio = T.fcSiiNumEnvio)
							  END, 0)                                    
		--*****************************
		, T.fcSiiFacCod
		, T.fcSiiFacPerCod
		, T.fcSiiFacCtrCod
		, T.fcSiiFacVersion
		, T.fcSiiNumEnvio
		INTO #TIPO1
		FROM dbo.vFacturasSiiPendientes AS T
		WHERE anyo = @anyo AND mes = @mes;

		--************************************
		--********* R E S U L T A D O ********
		--SYR-526780 SII Facturas sin iva: Solo se envían sin hay lineas en la factura
		WITH LINEAS AS(
		SELECT V.fcSiiFacCod
		, V.fcSiiFacPerCod
		, V.fcSiiFacCtrCod
		, V.fcSiiFacVersion
		, V.fcSiiNumEnvio
		, [lineas] = COUNT(D.fclSiiNumEnvio)
		FROM dbo.#TIPO1 AS V
		LEFT JOIN dbo.facSIIDesgloseFactura AS D
		ON  V.fcSiiFacCod = D.fclSiiFacCod
		AND V.fcSiiFacPerCod = D.fclSiiFacPerCod
		AND V.fcSiiFacCtrCod = D.fclSiiFacCtrCod
		AND V.fcSiiFacVersion = D.fclSiiFacVersion
		AND V.fcSiiNumEnvio = D.fclSiiNumEnvio
		GROUP BY V.fcSiiFacCod, V.fcSiiFacPerCod, V.fcSiiFacCtrCod, V.fcSiiFacVersion, V.fcSiiNumEnvio)
	
		--********* Solo aquellas que tienen lineas en el desglose ********
		SELECT fechaFactura
			 , serDesc
			 , fcSiiNumSerieFacturaEmisor
			 , fcSiiContraparteNombreRazon
			 , docIden
			 , info	
			 , [baseImponible] = CAST(ROUND(ISNULL(baseImponible,0),2) AS decimal(12,2))	
			 , [cuotaRepercutida] = CAST(ROUND(ISNULL(cuotaRepercutida,0),2) AS decimal(12,2))
		FROM #TIPO1 AS T
		LEFT JOIN LINEAS AS L
		ON T.fcSiiFacCod = L.fcSiiFacCod
		AND T.fcSiiFacPerCod = L.fcSiiFacPerCod
		AND T.fcSiiFacCtrCod = L.fcSiiFacCtrCod
		AND T.fcSiiFacVersion = L.fcSiiFacVersion
		AND T.fcSiiNumEnvio = L.fcSiiNumEnvio
		--SYR-526780: Caso de problema comentar el WHERE para volver a la version original
		WHERE L.lineas IS NOT NULL AND L.lineas > 0 
		ORDER BY  fechaFactura
				, T.fcSiiFacCod, T.fcSiiFacPerCod, T.fcSiiFacCtrCod, T.fcSiiFacVersion
				, fcSiiNumSerieFacturaEmisor, serdesc;
	END
	ELSE
	BEGIN
		--*****************************
		--#TIPO2: @tipo=2
		SELECT	[fechaFactura] = CONVERT(VARCHAR(10), facFecha, 103), 
		serDesc, 
		fcSiiNumSerieFacturaEmisor,
		fcSiiContraparteNombreRazon,
		[docIden] = ISNULL(fcSiiContraparteID, fcSiiContraparteNIF),
		[info] = IIF(fcSiiLoteID IS NULL, 'Pendiente de enviar', 'Pendiente de respuesta') 					
		, [baseImponible] = 0.0
		, [cuotaRepercutida]= 0.0 
		, f1.fcSiiFacCod, f1.fcSiiFacPerCod, f1.fcSiiFacCtrCod, f1.fcSiiFacVersion, f1.fcSiiNumEnvio
		, f1.fcSiiFechaExpedicionFacturaEmisor
		, f1.fcSiiLoteID
		INTO #TIPO2
		FROM dbo.facsii AS f1	
		INNER JOIN dbo.facturas 
		ON  facCtrCod = fcSiiFacCtrCod 
		AND facPerCod = fcSiiFacPerCod 
		AND facCod = fcSiiFacCod 
		AND facVersion = fcSiiFacVersion	
		INNER JOIN dbo.series
		ON  sercod = facsercod 
		AND serscd = facserscdCod
		WHERE fcSiiestado IS NULL
		AND EXISTS (SELECT fclFacCtrCod 
					FROM facLin 
					INNER JOIN servicios 
					ON  svcCod = fclTrfSvCod 
					AND svcOrgCod IS NULL	
					AND fclFacCtrCod = fcSiiFacCtrCod 
					AND fclFacVersion = fcSiiFacVersion 
					AND fcSiiFacCod = fclFacCod 
					AND fclFacPerCod = fcSiiFacPerCod)
		AND fcSiiNumEnvio = (SELECT MAX(f2.fcSiiNumEnvio)
							 FROM facSii f2
							 WHERE f1.fcSiiFacCod = f2.fcSiiFacCod 
							 AND f1.fcSiiFacCtrCod = f2.fcSiiFacCtrCod 
							 AND f1.fcSiiFacPerCod = f2.fcSiiFacPerCod 
							 AND f1.fcSiiFacVersion= f2.fcSiiFacVersion);
	
		--************************************
		--********* R E S U L T A D O ********
		--SYR-526780 SII Facturas sin iva: Solo se envían sin hay lineas en la factura
		WITH LINEAS AS(
		SELECT V.fcSiiFacCod
		, V.fcSiiFacPerCod
		, V.fcSiiFacCtrCod
		, V.fcSiiFacVersion
		, V.fcSiiNumEnvio
		, [lineas] = COUNT(D.fclSiiNumEnvio)
		, [loteID] = MAX(V.fcSiiLoteID)
		FROM #TIPO2 AS V
		LEFT JOIN dbo.facSIIDesgloseFactura AS D
		ON  V.fcSiiFacCod = D.fclSiiFacCod
		AND V.fcSiiFacPerCod = D.fclSiiFacPerCod
		AND V.fcSiiFacCtrCod = D.fclSiiFacCtrCod
		AND V.fcSiiFacVersion = D.fclSiiFacVersion
		AND V.fcSiiNumEnvio = D.fclSiiNumEnvio
		GROUP BY V.fcSiiFacCod, V.fcSiiFacPerCod, V.fcSiiFacCtrCod, V.fcSiiFacVersion, V.fcSiiNumEnvio)
	
		--********* Solo aquellas que tienen lineas en el desglose ********
		SELECT T.fechaFactura
		, T.serdesc
		, T.fcSiiNumSerieFacturaEmisor
		, T.fcSiiContraparteNombreRazon
		, T.docIden
		, T.info
		, T.baseImponible
		, T.cuotaRepercutida
		--, T.fcSiiLoteID
		FROM #TIPO2 AS T
		LEFT JOIN LINEAS AS L
		ON T.fcSiiFacCod = L.fcSiiFacCod
		AND T.fcSiiFacPerCod = L.fcSiiFacPerCod
		AND T.fcSiiFacCtrCod = L.fcSiiFacCtrCod
		AND T.fcSiiFacVersion = L.fcSiiFacVersion
		AND T.fcSiiNumEnvio = L.fcSiiNumEnvio
		--SYR-526780: Caso de problema comentar el WHERE para volver a la version original
		WHERE L.lineas IS NOT NULL AND L.lineas > 0
		ORDER BY fcSiiFechaExpedicionFacturaEmisor;
	END
END TRY
BEGIN CATCH	
END CATCH

IF OBJECT_ID('tempdb..#TIPO1') IS NOT NULL DROP TABLE #TIPO1;
IF OBJECT_ID('tempdb..#TIPO2') IS NOT NULL DROP TABLE #TIPO2;
GO


