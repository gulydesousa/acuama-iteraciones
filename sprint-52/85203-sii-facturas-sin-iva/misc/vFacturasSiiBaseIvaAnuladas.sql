USE [ACUAMA_GUADALAJARA_DESA]
GO

/****** Object:  View [dbo].[vFacturasSiiBaseIvaAnuladas]    Script Date: 03/04/2024 13:05:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vFacturasSiiBaseIvaAnuladas]
--WITH SCHEMABINDING
as
	select   fclSiiFacCtrCod 
            ,fclSiiFacPerCod 
            ,fclSiiFacCod 
            ,fclSiiFacVersion            
            ,fclSiiNumEnvio            
            ,fclSiiNumLinea
			,fcSiiTipoFactura			
            ,MONTH(facFecha) mes
            ,YEAR(facFecha)     anyo
            -------------------------------------                    
            ,fLAnt.fclSiiTipoImpositivo
            ,fclImpuesto
            ,iif(fLAnt.fclSiiTipoImpositivo=fclImpuesto,'si','NO') ok1
            -------------------------------------            
            ,fLAnt.fclSiiBaseImponible * - 1								fclSiiBaseImponible
			,cast(round(fLAnt.fclSiiBaseImponible,2) AS decimal(12,2)) * -1	fclSiiBaseImponibleRound2
            ,fclBase * -1													fclBase
            ,iif(fLAnt.fclSiiBaseImponible=fclBase,'si','NO')				ok2
            -------------------------------------            
            ,fLAnt.fclSiiCuotaRepercutida * -1									fclSiiCuotaRepercutida
			,cast(round(fLAnt.fclSiiCuotaRepercutida,2) AS decimal(12,2)) * -1	fclSiiCuotaRepercutidaRound2
            ,fclImpImpuesto * -1												fclImpImpuesto
            ,iif(fLAnt.fclSiiCuotaRepercutida=fclImpImpuesto,'si','NO')			ok3
            -------------------------------------                            
    FROM dbo.facSii fs
    INNER JOIN dbo.facturas                     ON facCtrCod                = fcSiiFacCtrCod 
                                               AND facPerCod                = fcSiiFacPerCod 
                                               AND facCod                   = fcSiiFacCod 
                                               AND facVersion				= fcSiiFacVersion
											   AND fs.fcSiiTipoFactura      = 'AN'
											   
	INNER JOIN dbo.facLin                       ON fclFacCtrCod             = FacCtrCod
                                               AND fclFacPerCod             = FacPerCod
                                               AND fclFacCod                = FacCod
                                               AND fclFacVersion            = FacVersion-1											   
    -- HACEMOS LEFT JOIN POR SI EL PASO DE FACLIN A facSIIDesgloseFactura FALLARA
	-- ASI TENDREMOS CONSTANCIA CUANDO SACARAN LOS INFORMES
    LEFT JOIN dbo.facSIIDesgloseFactura fLAnt   ON fLAnt.fclSiiFacCtrCod	= fcSiiFacCtrCod 
                                               AND fLAnt.fclSiiFacPerCod	= fcSiiFacPerCod 
                                               AND fLAnt.fclSiiFacCod		= fcSiiFacCod 
                                               AND fLAnt.fclSiiFacVersion	= fcSiiFacVersion-1 
                                               AND fLAnt.fclSiiNumLinea		= fclNumLinea
                                               AND fLAnt.fclSiiNumEnvio		= ( SELECT MAX(fcSiiNumEnvio)
                                                                                FROM dbo.facSii v		                                                                             
                                                                                where v.fcSiiFacPerCod  = fs.fcSiiFacPerCod
                                                                                  and v.fcSiiFacCtrCod  = fs.fcSiiFacCtrCod
                                                                                  and v.fcSiiFacVersion = fs.fcSiiFacVersion - 1)  
	/*
    select   fl.fclSiiFacCtrCod 
            ,fl.fclSiiFacPerCod 
            ,fl.fclSiiFacCod 
            ,fl.fclSiiFacVersion            
            ,fl.fclSiiNumEnvio
            ,fl.fclSiiNumLinea            
            ,fcSiiTipoFactura
            ,MONTH(facFecha) mes
            ,YEAR(facFecha)     anyo
            -------------------------------------                    
            ,fLAnt.fclSiiTipoImpositivo
            ,fclImpuesto
            ,iif(fLAnt.fclSiiTipoImpositivo=fclImpuesto,'si','no') ok1
            -------------------------------------            
            ,fLAnt.fclSiiBaseImponible * 1                       fclSiiBaseImponible
            ,fclBase * -1                                        fclBase
            ,iif(fLAnt.fclSiiBaseImponible=fclBase,'si','no')    ok2
            -------------------------------------            
            ,fLAnt.fclSiiCuotaRepercutida * 1                           fclSiiCuotaRepercutida
            ,fclImpImpuesto * -1                                        fclImpImpuesto
            ,iif(fLAnt.fclSiiCuotaRepercutida=fclImpImpuesto,'si','no') ok3
            -------------------------------------                        
    FROM dbo.facSIIDesgloseFactura fl
    INNER JOIN dbo.facSii fs                    ON fs.fcSiiFacCtrCod        = fclSiiFacCtrCod
                                               AND fs.fcSiiFacPerCod        = fclSiiFacPerCod    
                                               AND fs.fcSiiFacCod           = fclSiiFacCod        
                                               AND fs.fcSiiFacVersion       = fclSiiFacVersion    
                                               AND fs.fcSiiNumEnvio         = fclSiiNumEnvio
                                               AND fs.fcSiiTipoFactura      = 'AN'                                                              
    INNER JOIN dbo.facturas                     ON facCtrCod                = fclSiiFacCtrCod 
                                               AND facPerCod                = fclSiiFacPerCod 
                                               AND facCod                   = fclSiiFacCod 
                                               AND facVersion				= fclSiiFacVersion
    LEFT JOIN dbo.facSIIDesgloseFactura fLAnt   ON fLAnt.fclSiiFacCtrCod	= fL.fclSiiFacCtrCod 
                                               AND fLAnt.fclSiiFacPerCod    = fL.fclSiiFacPerCod 
                                               AND fLAnt.fclSiiFacCod       = fL.fclSiiFacCod 
                                               AND fLAnt.fclSiiFacVersion   = fL.fclSiiFacVersion-1 
                                               AND fLAnt.fclSiiNumLinea     = fL.fclSiiNumLinea
                                               AND fLAnt.fclSiiNumEnvio     = ( SELECT MAX(fcSiiNumEnvio)
                                                                                FROM dbo.facSii v		                                                                             
                                                                                where v.fcSiiFacPerCod  = fs.fcSiiFacPerCod
                                                                                  and v.fcSiiFacCtrCod  = fs.fcSiiFacCtrCod
                                                                                  and v.fcSiiFacVersion = fs.fcSiiFacVersion - 1)                                                                                 
    LEFT JOIN dbo.facLin                        ON fclFacCtrCod             = fl.fclSiiFacCtrCod
                                               AND fclFacPerCod             = fl.fclSiiFacPerCod
                                               AND fclFacCod                = fl.fclSiiFacCod
                                               AND fclFacVersion            = fl.fclSiiFacVersion-1
                                               AND fclNumLinea              = fl.fclSiiNumLinea*/


/*

select top 100 * from facSIIDesgloseFactura

select top 10 * from facLin

--15 ANULADAS

Select FS.* 
from facSII FS
INNER JOIN dbo.facturas ON facCtrCod        = fcSiiFacCtrCod 
                        AND facPerCod        = fcSiiFacPerCod 
                        AND facCod            = fcSiiFacCod 
                        AND facVersion        = fcSiiFacVersion
                        AND fcSiiTipoFactura = 'AN'
                        AND MONTH(FACFECHA) = 4
                        AND YEAR(FACFECHA) = 2020


select fclSiiFacCtrCod,fclSiiFacPerCod,fclSiiFacCod,fclSiiFacVersion
from vFacturasSiiBaseIvaAnuladas
where mes=4
 and anyo=2020
group by fclSiiFacCtrCod,fclSiiFacPerCod,fclSiiFacCod,fclSiiFacVersion


select * from vFacturasSiiBaseIvaAnuladas
where mes=4
 and anyo=2020
order by 1,2,3,4

select sum(fclSiiBaseImponible) base,sum(fclSiiCuotaRepercutida) ImporteImpuesto
from vFacturasSiiBaseIvaAnuladas
where mes=4
  and anyo=2020

drop INDEX idx_facSII_vFacturasSiiBaseIvaAnuladas on facSII

CREATE NONCLUSTERED INDEX idx_facSII_vFacturasSiiBaseIvaAnuladas
ON [dbo].[facSII] ([fcSiiTipoFactura])
INCLUDE ([fcSiiFacCod],[fcSiiFacPerCod],[fcSiiFacCtrCod],[fcSiiFacVersion],[fcSiiNumEnvio])

*/

GO


