USE [ACUAMA_GUADALAJARA_DESA]
GO

/****** Object:  View [dbo].[vFacturasSiiPendientes]    Script Date: 03/04/2024 11:20:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM InformeFacturasSiiPendientes WHERE mes=4 AND anyo=2024

CREATE view [dbo].[vFacturasSiiPendientes]
--WITH SCHEMABINDING
as	
	/*
	 * Facturas pendientes serán aquellas con estado a nulo y no haya fallado el lote, y además su número de envio
	 * sea el máximo existente para la factura en el periodo buscado, ya que sino fuera el máximo es que se ha  
	 * producido un nuevo envio de la misma y ya existe un nuevo estado para la misma.
	 */
	select   t.fcSiiFacCod
			,t.fcSiiFacPerCod
		    ,t.fcSiiFacCtrCod
		    ,t.fcSiiFacVersion
		    ,t.fcSiiNumEnvio
			,t.fcSiiTipoFactura
			,fcSiiNumSerieFacturaEmisor
			,fcSiiContraparteNombreRazon
			,docIden
			,info
			,fechaFactura
			,t.mes
			,t.anyo
			,serdesc
			,fcSiiLoteID
	from   (
			SELECT	 fs.fcSiiFacCod
					,fs.fcSiiFacPerCod
					,fs.fcSiiFacCtrCod
					,fs.fcSiiFacVersion
					,fs.fcSiiNumEnvio
					,fs.fcSiiNumSerieFacturaEmisor
					,fs.fcSiiContraparteNombreRazon
					,fs.fcSiiTipoFactura
					,ISNULL(fcSiiContraparteID, fcSiiContraparteNIF)                         docIden
					,iif(fs.fcSiiLoteID IS NULL,'Pendiente de enviar','Pendiente de respuesta') info
					,facFecha			fechaFactura
					,month(facFecha)	mes
					,year(facFecha)		anyo	
					,s.serdesc
					,fs.fcSiiLoteID
			FROM DBO.facsii fs
			INNER JOIN DBO.facturas	    ON facCtrCod	= fcSiiFacCtrCod 
									   AND facPerCod	= fcSiiFacPerCod 
									   AND facCod		= fcSiiFacCod 
									   AND facVersion	= fcSiiFacVersion
									   AND fcSiiestado	IS NULL
			INNER JOIN dbo.series s     ON sercod       = facsercod 
									   AND serscd		= facserscdCod
			LEFT JOIN  dbo.vFacturasSiiEstadoRechazadoPorLoteErroneo V  on V.fcSiiFacCod	= fs.fcSiiFacCod	
	                                                                   AND V.fcSiiFacPerCod	= fs.fcSiiFacPerCod	
									                                   AND V.fcSiiFacCtrCod	= fs.fcSiiFacCtrCod	
									                                   AND V.fcSiiFacVersion= fs.fcSiiFacVersion
									                                   AND V.fcSiiNumEnvio	= fs.fcSiiNumEnvio
																	   AND V.mes			= month(facFecha)
																	   AND V.anyo			= year(facFecha)

			WHERE V.fcSiiFacCod IS NULL
			) T
    INNER JOIN dbo.vNumEnvioMaxFacSii V	ON V.fcSiiFacCod	    = t.fcSiiFacCod	
	                                   AND V.fcSiiFacPerCod	    = t.fcSiiFacPerCod	
									   AND V.fcSiiFacCtrCod	    = t.fcSiiFacCtrCod	
									   AND V.fcSiiFacVersion    = t.fcSiiFacVersion
									   AND V.maxFcSiiNumEnvio	= t.fcSiiNumEnvio
									   AND V.mes			    = t.mes
									   AND V.anyo			    = t.anyo


/*

-- 8
SELECT * 
FROM vFacturasSiiPendientes
WHERE MES=4
AND ANYO=2020

ORDER BY fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion

SELECT fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion
FROM vFacturasSiiPendientes
WHERE MES=4
AND ANYO=2020
GROUP BY fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion

fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,fcSiiNumEnvio,fcSiiCodErr,fcSiiLoteID,fechaFactura,mes,anyo


select * from vFacturasSiiEstadoRechazadoPorLoteErroneo
WHERE MES=4
AND ANYO=2020
*/

GO


