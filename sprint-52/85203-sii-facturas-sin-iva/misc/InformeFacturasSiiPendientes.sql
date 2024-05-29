USE [ACUAMA_GUADALAJARA_DESA]
GO

/****** Object:  StoredProcedure [dbo].[InformeFacturasSiiPendientes]    Script Date: 03/04/2024 12:46:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--EXEC InformeFacturasSiiPendientes 1,2024, 4

CREATE procedure [dbo].[InformeFacturasSiiPendientes]	
     @mes				int		= null
    ,@anyo				int		= null
	,@tipo				int		-- tipo 1 por mes año,2 todas las pendientes
as

	IF @tipo = 1 
		
		BEGIN

			SELECT	 fechaFactura
					,serDesc
					,fcSiiNumSerieFacturaEmisor
					,fcSiiContraparteNombreRazon
					,docIden
					,info	
					,CAST(ROUND(ISNULL(baseImponible,0),2) AS decimal(12,2))	baseImponible
					,CAST(ROUND(ISNULL(cuotaRepercutida,0),2) AS decimal(12,2)) cuotaRepercutida
			FROM (	SELECT	 CONVERT(VARCHAR(10), fechaFactura, 103) AS fechaFactura
							,serDesc
							,fcSiiNumSerieFacturaEmisor
							,fcSiiContraparteNombreRazon
							,docIden
							,info					
							-----------------------------------------------------------------------------------------------------                
							-----------------------------------------------------------------------------------------------------
							,isnull(CASE WHEN fcSiiTipoFactura = 'AN' THEN (select sum(fclSiiBaseImponible)                        
																			from vFacturasSiiBaseIvaAnuladas v
																			where v.fclSiiFacCtrCod = fcSiiFacCtrCod
																			  and v.fclSiiFacPerCod = fcSiiFacPerCod
																			  and v.fclSiiFacCod    = fcSiiFacCod
																			  and v.fclSiiFacVersion= fcSiiFacVersion
																			  and v.fclSiiNumEnvio  = fcSiiNumEnvio)                                                                  
							ELSE 
								(select sum(fclSiiBaseImponible)
								from vFacturasSiiBaseIvaNoAnuladas v
								where v.fclSiiFacCtrCod    = fcSiiFacCtrCod
								  and v.fclSiiFacPerCod    = fcSiiFacPerCod
								  and v.fclSiiFacCod       = fcSiiFacCod
								  and v.fclSiiFacVersion   = fcSiiFacVersion
								  and v.fclSiiNumEnvio     = fcSiiNumEnvio)
							END,0) AS baseImponible    
    
							,isnull(CASE WHEN fcSiiTipoFactura = 'AN' THEN (select sum(fclSiiCuotaRepercutida)                        
																			from vFacturasSiiBaseIvaAnuladas v
																			where v.fclSiiFacCtrCod = fcSiiFacCtrCod
																			  and v.fclSiiFacPerCod = fcSiiFacPerCod
																			  and v.fclSiiFacCod	= fcSiiFacCod
																			  and v.fclSiiFacVersion= fcSiiFacVersion
																			  and v.fclSiiNumEnvio  = fcSiiNumEnvio)    
							ELSE 
								(select sum(fclSiiCuotaRepercutida)                        
								 from vFacturasSiiBaseIvaNoAnuladas v
								 where v.fclSiiFacCtrCod    = fcSiiFacCtrCod
								   and v.fclSiiFacPerCod    = fcSiiFacPerCod
								   and v.fclSiiFacCod       = fcSiiFacCod
								   and v.fclSiiFacVersion   = fcSiiFacVersion
								   and v.fclSiiNumEnvio     = fcSiiNumEnvio)
							END,0) AS cuotaRepercutida                                   
							-----------------------------------------------------------------------------------------------------
							-----------------------------------------------------------------------------------------------------
							,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion
					FROM vFacturasSiiPendientes
					WHERE anyo	= @anyo
					  AND mes	= @mes	
			) T					  
			ORDER BY fechaFactura, fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,fcSiiNumSerieFacturaEmisor,serdesc

		END

	ELSE

		BEGIN

			SELECT	CONVERT(VARCHAR(10), facFecha, 103) AS fechaFactura, 
					serDesc, 
					fcSiiNumSerieFacturaEmisor,
					fcSiiContraparteNombreRazon,
					ISNULL(fcSiiContraparteID, fcSiiContraparteNIF)							docIden,
					iif(fcSiiLoteID IS NULL,'Pendiente de enviar','Pendiente de respuesta') info					
					,0.0 baseImponible
					,0.0 cuotaRepercutida
			FROM facsii f1
			INNER JOIN facturas ON facCtrCod	= fcSiiFacCtrCod 
			                   AND facPerCod	= fcSiiFacPerCod 
			                   AND facCod		= fcSiiFacCod 
			                   AND facVersion	= fcSiiFacVersion
			INNER JOIN series	ON sercod		= facsercod 
			                   AND serscd		= facserscdCod
			WHERE fcSiiestado IS NULL
			  AND EXISTS (	SELECT fclFacCtrCod 
							FROM facLin 
							INNER JOIN servicios ON svcCod			= fclTrfSvCod 
												AND svcOrgCod		IS NULL	
												AND fclFacCtrCod	= fcSiiFacCtrCod 
												AND fclFacVersion	= fcSiiFacVersion 
												AND fcSiiFacCod		= fclFacCod 
												AND fclFacPerCod	= fcSiiFacPerCod)
			  AND fcSiiNumEnvio = (	SELECT MAX(f2.fcSiiNumEnvio)
									FROM facSii f2
									WHERE f1.fcSiiFacCod	= f2.fcSiiFacCod 
									  AND f1.fcSiiFacCtrCod = f2.fcSiiFacCtrCod 
									  AND f1.fcSiiFacPerCod = f2.fcSiiFacPerCod 
									  AND f1.fcSiiFacVersion= f2.fcSiiFacVersion)
			ORDER BY fcSiiFechaExpedicionFacturaEmisor

		END
GO


