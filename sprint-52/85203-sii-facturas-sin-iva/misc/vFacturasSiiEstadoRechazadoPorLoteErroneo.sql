USE [ACUAMA_GUADALAJARA_DESA]
GO

/****** Object:  View [dbo].[vFacturasSiiEstadoRechazadoPorLoteErroneo]    Script Date: 03/04/2024 11:21:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vFacturasSiiEstadoRechazadoPorLoteErroneo]
--WITH SCHEMABINDING
as

    /*
	 * Facturas rechazadas por que su lote fallo,serán aquellas facturas que su lote haya fallado
	 */
	SELECT	 fs.fcSiiFacCod
			,fs.fcSiiFacPerCod
			,fs.fcSiiFacCtrCod
			,fs.fcSiiFacVersion
			,fs.fcSiiNumEnvio							
			,ISNULL(fs.fcSiiCodErr,fcSiiLtIdError)			fcSiiCodErr
			,isnull(fcSiidescErr,fcSiiLtErrorDescripcion)	fcSiidescErr			
			,facFecha										fechaFactura
			,month(facFecha)								mes
			,year(facFecha)									anyo
			,serdesc
			,fcSiiNumSerieFacturaEmisor
			,fcSiiContraparteNombreRazon
			,fs.fcSiiCabTitNombreRazon
			,fs.fcSiiLoteID
			,ISNULL(fcSiiContraparteID, fcSiiContraparteNIF)	docIden
			,fcSiiTipoFactura
	FROM DBO.facsii fs
	INNER JOIN dbo.facSIILote	ON fcSiiLtID		= fcSiiLoteID
							   AND (fcSiiLtEstado	= 'E' or (fcSiiLtEstado	='W' and fcSiiLtIdError=4206))
							   AND fcSiiestado		IS NULL								   
							 --and fcSiiLtEnvEstado = 'E' 									   
	INNER JOIN DBO.facturas		ON facCtrCod		= FS.fcSiiFacCtrCod 
	                           AND facPerCod		= FS.fcSiiFacPerCod 
					           AND facCod			= FS.fcSiiFacCod 
					           AND facVersion		= FS.fcSiiFacVersion
	INNER JOIN dbo.series	    ON sercod			= facsercod 
                               AND serscd			= facserscdCod
/*

select * from vFacturasSiiEstadoRechazadoPorLoteErroneo

-- 1000
select * from vFacturasSiiEstadoRechazadoPorLoteErroneo
where mes=4
and anyo=2020

select fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion
from vFacturasSiiEstadoRechazadoPorLoteErroneo
where mes=4
and anyo=2020
GROUP BY fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion

select * from facSII Lote

*/
GO


