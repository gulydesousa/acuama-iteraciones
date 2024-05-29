--Selecciona el ultimo envio válido 
DECLARE @mes INT = 3
DECLARE @anyo INT = 2024
DECLARE @tipo INT = 1;
EXEC InformeFacturasSiiPendientes @tipo,@anyo , @mes
--**********************************
--[01]Fechas en consulta
DECLARE @fechaD DATE= DATEFROMPARTS(@anyo, @mes, 1);
DECLARE @fechaH DATE = DATEADD(MONTH, 1, @fechaD);

--BEGIN TRY

	--***********************************
	--[02]#ULTIMO_ENVIO: Nos quedamos con el ultimo envio (o el penultimo, si estaba aceptado)
	WITH ENVIOS AS(
	--Envios: Agrupados y ordenados por mes y año
	SELECT S.fcSiiFacCod
	, S.fcSiiFacPerCod
	, S.fcSiiFacCtrCod
	, S.fcSiiFacVersion
	, S.fcSiiNumEnvio
	--*****************
	, S.fcSiiTipoFactura
	, [aceptado] = CASE WHEN S.fcSiiestado IS NULL THEN 0
					WHEN S.fcSiiestado IN (1, 2) THEN 1
					WHEN S.fcSiiestado IN (3) AND S.fcSiiCodErr = 3000 THEN 1
					ELSE 0 END
	--*****************
	, facFecha = CAST(F.facFecha AS DATE)
	, Mes= MONTH(F.facFecha)
	, Anyo= YEAR(F.facFecha)
	--*****************
	--RN=1: Para obtener el ultimo envio
	, RN = ROW_NUMBER() OVER (PARTITION BY S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion
							, YEAR(F.facFecha), MONTH(F.facFecha) 
							ORDER BY S.fcSiiNumEnvio DESC)
	FROM dbo.facSII AS S
	INNER JOIN dbo.facturas AS F
	ON  F.facCod = S.fcSiiFacCod AND 
	F.facCtrCod = S.fcSiiFacCtrCod AND 
	F.facPerCod = S.fcSiiFacPerCod AND 
	F.facVersion = S.fcSiiFacVersion AND 
	F.facFecha >=@fechaD AND F.facFecha<@fechaH)

	SELECT [fcSiiNumEnvio] = IIF(E0.aceptado IS NOT NULL AND E0.aceptado=1, E0.fcSiiNumEnvio, E.fcSiiNumEnvio)
	, [aceptado] = IIF(E0.aceptado IS NOT NULL AND E0.aceptado=1, E0.aceptado, E.aceptado)
	, [fcSiiTipoFactura] = IIF(E0.aceptado IS NOT NULL AND E0.aceptado=1, E0.fcSiiTipoFactura, E.fcSiiTipoFactura)
	, E.fcSiiFacCod
	, E.fcSiiFacPerCod
	, E.fcSiiFacCtrCod
	, E.fcSiiFacVersion
	, E.Mes
	, E.Anyo
	, E.facFecha
	INTO #ULTIMO_ENVIO
	FROM ENVIOS AS E
	LEFT JOIN ENVIOS AS E0 ON 
	E.fcSiiFacCod = E0.fcSiiFacCod AND 
	E.fcSiiFacPerCod = E0.fcSiiFacPerCod AND 
	E.fcSiiFacCtrCod = E0.fcSiiFacCtrCod AND 
	E.fcSiiFacVersion = E0.fcSiiFacVersion AND 
	E0.RN=2 --Envio anterior
	WHERE E.RN=1; --Ultimo envio del mes

	--***********************************
	--[03]#TOTALES: Totaliza el desglose de lineas
	--Para las anuladas, recuperamos el total de la version anterior de la factura.
	WITH TOTALES AS(
	--Totaliza el desglose de lineas
	SELECT E.fcSiiFacCod, E.fcSiiFacPerCod, E.fcSiiFacCtrCod, E.fcSiiFacVersion, E.fcSiiNumEnvio 
	, E.fcSiiTipoFactura
	, [baseImponible] = SUM(ROUND(D.fclSiiBaseImponible, 2))
	, [cuotaRepercutida] = SUM(ROUND(D.fclSiiCuotaRepercutida, 2))
	, [lineas] = COUNT(D.fclSiiNumEnvio)
	FROM #ULTIMO_ENVIO AS E
	LEFT JOIN dbo.facSIIDesgloseFactura AS D
	ON E.fcSiiFacCod = D.fclSiiFacCod
	AND E.fcSiiFacPerCod = D.fclSiiFacPerCod
	AND E.fcSiiFacCtrCod = D.fclSiiFacCtrCod
	AND E.fcSiiFacVersion = D.fclSiiFacVersion
	AND E.fcSiiNumEnvio = D.fclSiiNumEnvio
	GROUP BY E.fcSiiFacCod, E.fcSiiFacPerCod, E.fcSiiFacCtrCod, E.fcSiiFacVersion, E.fcSiiNumEnvio, E.fcSiiTipoFactura

	), ANULADAS AS(
	--Para las anuladas, sacamos el importe de la factura que anula (la version anterior)
	SELECT U.fcSiiFacCod, U.fcSiiFacPerCod, U.fcSiiFacCtrCod, U.fcSiiFacVersion, U.fcSiiNumEnvio
	, [baseImponible] = SUM(ROUND(D.fclSiiBaseImponible, 2))
	, [cuotaRepercutida] = SUM(ROUND(D.fclSiiCuotaRepercutida, 2))
	, [lineas] = COUNT(D.fclSiiNumEnvio)
	FROM #ULTIMO_ENVIO AS U
	LEFT JOIN dbo.facSII AS S
	ON U.fcSiiFacCod = S.fcSiiFacCod
	AND U.fcSiiFacPerCod = S.fcSiiFacPerCod
	AND U.fcSiiFacCtrCod = S.fcSiiFacCtrCod
	AND S.fcSiiFacVersion = U.fcSiiFacVersion -1
	LEFT JOIN dbo.facSIIDesgloseFactura AS D
	ON S.fcSiiFacCod = D.fclSiiFacCod
	AND S.fcSiiFacPerCod = D.fclSiiFacPerCod
	AND S.fcSiiFacCtrCod = D.fclSiiFacCtrCod
	AND S.fcSiiFacVersion = D.fclSiiFacVersion
	AND S.fcSiiNumEnvio = D.fclSiiNumEnvio
	WHERE U.fcSiiTipoFactura = 'AN'
	GROUP BY U.fcSiiFacCod, U.fcSiiFacPerCod, U.fcSiiFacCtrCod, U.fcSiiFacVersion, U.fcSiiNumEnvio, U.fcSiiTipoFactura)

	SELECT T.fcSiiFacCod, T.fcSiiFacPerCod, T.fcSiiFacCtrCod, T.fcSiiFacVersion, T.fcSiiNumEnvio
	, T.fcSiiTipoFactura
	, T.lineas
	, [baseImponible] = IIF(T.fcSiiTipoFactura= 'AN', A.baseImponible*-1, T.baseImponible)
	, [cuotaRepercutida] =  IIF(T.fcSiiTipoFactura= 'AN', A.cuotaRepercutida*-1, T.cuotaRepercutida)
	INTO #TOTALES
	FROM TOTALES AS T
	LEFT JOIN ANULADAS AS A
	ON T.fcSiiFacCod = A.fcSiiFacCod
	AND T.fcSiiFacPerCod = A.fcSiiFacPerCod
	AND T.fcSiiFacCtrCod = A.fcSiiFacCtrCod
	AND T.fcSiiFacVersion = A.fcSiiFacVersion
	AND T.fcSiiNumEnvio = A.fcSiiNumEnvio;

	--***********************************
	--[04]RESULT: Union de todos los resultados
	SELECT E.fcSiiFacCod, E.fcSiiFacPerCod, E.fcSiiFacCtrCod, E.fcSiiFacVersion, E.fcSiiNumEnvio
	, [fechaFactura] = E.facFecha
	, [serDesc] = SS.serdesc
	, S.fcSiiestado
	, S.fcSiiNumSerieFacturaEmisor
	, S.fcSiiContraparteNombreRazon
	, [docIden] = ISNULL(S.fcSiiContraparteID, S.fcSiiContraparteNIF) 
				
	, [RechazadaxLoteErroneo] = CASE WHEN S.fcSiiestado IS NOT NULL THEN 0 
									 WHEN (L.fcSiiLtEstado= 'E') THEN 1
									 WHEN (L.fcSiiLtEstado= 'W' AND L.fcSiiLtIdError=4206) THEN 1
									 ELSE 0 END
	, T.[baseImponible]
	, T.[cuotaRepercutida]
	, T.lineas
	, E.aceptado	
	, S.fcSiiLoteID
	, S.fcSiicodErr
	, S.fcSiiTipoFactura
	INTO #RESULT
	FROM #ULTIMO_ENVIO AS E
	INNER JOIN dbo.facSII AS S
	ON S.fcSiiFacCod = E.fcSiiFacCod
	AND S.fcSiiFacCtrCod = E.fcSiiFacCtrCod
	AND S.fcSiiFacPerCod = E.fcSiiFacPerCod
	AND S.fcSiiFacVersion = E.fcSiiFacVersion
	AND S.fcSiiNumEnvio = E.fcSiiNumEnvio
	LEFT JOIN #TOTALES AS T
	ON T.fcSiiFacCod = E.fcSiiFacCod
	AND T.fcSiiFacCtrCod = E.fcSiiFacCtrCod
	AND T.fcSiiFacPerCod = E.fcSiiFacPerCod
	AND T.fcSiiFacVersion = E.fcSiiFacVersion
	AND T.fcSiiNumEnvio = E.fcSiiNumEnvio
	LEFT JOIN dbo.facSIILote AS L
	ON L.fcSiiLtID = S.fcSiiLoteID
	LEFT JOIN dbo.facturas AS F
	ON F.facCod = E.fcSiiFacCod
	AND F.facPerCod = E.fcSiiFacPerCod
	AND F.facCtrCod = E.fcSiiFacCtrCod
	AND F.facVersion = E.fcSiiFacVersion
	LEFT JOIN dbo.series AS SS
	ON SS.sercod = F.facSerCod
	AND SS.serscd = F.facSerScdCod;

	SELECT [fechaFactura] 
	, [serDesc]
	, [fcSiiNumSerieFacturaEmisor]
	, [fcSiiContraparteNombreRazon]
	, [dociden]
	, [info] = CASE WHEN R.[aceptado] = 1 THEN 'Aceptado'
					WHEN R.fcSiiLoteID IS NULL AND ISNULL(R.lineas, 0) = 0 THEN 'Sin cuota repercutida'
					WHEN R.fcSiiLoteID IS NULL AND R.lineas > 0 THEN 'Pendiente Respuesta'
					WHEN R.[RechazadaxLoteErroneo] = 1 THEN 'Rechazado por lote erroneo'				
					ELSE '' END
	, [baseImponible]
	, [cuotaRepercutida]
	, [fcSiiTipoFactura]
	FROM #RESULT AS R
	WHERE (@tipo IS NULL OR (R.[RechazadaxLoteErroneo]=0 AND R.fcSiiestado IS NULL))
	ORDER BY fechaFactura
	, R.fcSiiFacCod
	, R.fcSiiFacPerCod
	, R.fcSiiFacCtrCod
	, R.fcSiiFacVersion
	, R.fcSiiNumSerieFacturaEmisor
	, R.serdesc;
--END TRY
--BEGIN CATCH
--END CATCH
DROP TABLE  IF EXISTS #ULTIMO_ENVIO;
DROP TABLE  IF EXISTS #TOTALES;
DROP TABLE  IF EXISTS #RESULT;


--SELECT * FROM facSIILote WHERE fcSiiLtID='6D3F463D-44AA-48EC-834B-E4305549A244'
