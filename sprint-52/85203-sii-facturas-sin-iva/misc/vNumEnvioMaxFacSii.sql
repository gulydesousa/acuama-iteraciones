USE [ACUAMA_GUADALAJARA_DESA]
GO

/****** Object:  View [dbo].[vNumEnvioMaxFacSii]    Script Date: 03/04/2024 11:27:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vNumEnvioMaxFacSii]
--WITH SCHEMABINDING
as
	/*
	 * EL NUMERO MAXIMO DE ENVIO SERA EL MAYOR fcSiiNumEnvio DE UNA FACTURA EXCEPTO, PARA AQUELLAS
	 * QUE SU ULTIMO fcSiiNumEnvio TENGA ESTADO NULO Y EL fcSiiNumEnvio-1 TENGA UN ESTADO APROBADO
	 */
    
	WITH cte (maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,mes,anyo) as
	(
		SELECT MAX(f3.fcSiiNumEnvio) maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
		FROM dbo.facSii f3 
		INNER JOIN dbo.facturas ON facCtrCod	= fcSiiFacCtrCod 
							   AND facPerCod	= fcSiiFacPerCod 
							   AND facCod		= fcSiiFacCod 
							   AND facVersion	= fcSiiFacVersion 						
		group by fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha),YEAR(facFecha)
	)
	,CTE2 (maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,mes,anyo) AS
	(
		-- AQUI OBTENEMOS LAS FACTURAS QUE TIENEN EL NUMERO DE ENVIO INMEDIATAMENTE INFERIOR 
		-- AL NÚMERO MAXIMO DE ENVIO  QUE ESTEN EN ESTADO ACEPTADO
		SELECT FS.fcSiiNumEnvio,FS.fcSiiFacCod,FS.fcSiiFacPerCod,FS.fcSiiFacCtrCod,FS.fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
		FROM dbo.facSii fs
		INNER JOIN dbo.facturas ON facCtrCod			= FS.fcSiiFacCtrCod 
							   AND facPerCod			= FS.fcSiiFacPerCod 
							   AND facCod				= FS.fcSiiFacCod 
							   AND facVersion			= FS.fcSiiFacVersion 
							   AND (FS.fcSiiestado		in (1,2) or (FS.fcSiiestado=3 AND fcSiiCodErr = 3000 ))
		INNER JOIN cte	T		ON T.fcSiiFacCod		= FS.fcSiiFacCod	
							   AND T.fcSiiFacPerCod		= FS.fcSiiFacPerCod	
							   AND T.fcSiiFacCtrCod		= FS.fcSiiFacCtrCod	
							   AND T.fcSiiFacVersion	= FS.fcSiiFacVersion
							   AND T.maxFcSiiNumEnvio-1	= FS.fcSiiNumEnvio	
							   
		
	)
	
	SELECT maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,mes,anyo
	FROM cte
	EXCEPT
	SELECT maxFcSiiNumEnvio+1,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,mes,anyo
	FROM CTE2
	UNION ALL
	SELECT maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,mes,anyo
	FROM CTE2

	ORDER BY anyo, mes,  fcSiiFacCtrCod, fcSiiFacPerCod, fcSiiFacCod, fcSiiFacVersion
	

	/*
	SELECT maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,mes,anyo
	FROM (
			SELECT MAX(f3.fcSiiNumEnvio) maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
			FROM dbo.facSii f3 
			INNER JOIN dbo.facturas ON facCtrCod	= fcSiiFacCtrCod 
									AND facPerCod	= fcSiiFacPerCod 
									AND facCod		= fcSiiFacCod 
									AND facVersion	= fcSiiFacVersion 						
			group by fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha),YEAR(facFecha)
			except	
			SELECT FS.fcSiiNumEnvio+1,FS.fcSiiFacCod,FS.fcSiiFacPerCod,FS.fcSiiFacCtrCod,FS.fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
			FROM dbo.facSii fs
			INNER JOIN dbo.facturas ON facCtrCod			= FS.fcSiiFacCtrCod 
									AND facPerCod			= FS.fcSiiFacPerCod 
									AND facCod				= FS.fcSiiFacCod 
									AND facVersion			= FS.fcSiiFacVersion 
									AND (FS.fcSiiestado		in (1,2) or (FS.fcSiiestado=3 AND fcSiiCodErr = 3000 ))
			INNER JOIN (SELECT MAX(f3.fcSiiNumEnvio) maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
						FROM dbo.facSii f3 
						INNER JOIN dbo.facturas ON facCtrCod	= fcSiiFacCtrCod 
												AND facPerCod	= fcSiiFacPerCod 
												AND facCod		= fcSiiFacCod 
												AND facVersion	= fcSiiFacVersion 						
						group by fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha),YEAR(facFecha)) T	ON T.fcSiiFacCod		= FS.fcSiiFacCod	
																															   AND T.fcSiiFacPerCod		= FS.fcSiiFacPerCod	
																															   AND T.fcSiiFacCtrCod		= FS.fcSiiFacCtrCod	
																															   AND T.fcSiiFacVersion	= FS.fcSiiFacVersion
																															   AND T.maxFcSiiNumEnvio-1	= FS.fcSiiNumEnvio
			UNION ALL
			-- AQUI OBTENEMOS LAS FACTURAS QUE TIENEN EL NUMERO DE ENVIO INMEDIATAMENTE INFERIOR 
			-- AL NÚMERO MAXIMO DE ENVIO  QUE ESTEN EN ESTADO ACEPTADO
			SELECT FS.fcSiiNumEnvio+1,FS.fcSiiFacCod,FS.fcSiiFacPerCod,FS.fcSiiFacCtrCod,FS.fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
			FROM dbo.facSii fs
			INNER JOIN dbo.facturas ON facCtrCod			= FS.fcSiiFacCtrCod 
									AND facPerCod			= FS.fcSiiFacPerCod 
									AND facCod				= FS.fcSiiFacCod 
									AND facVersion			= FS.fcSiiFacVersion 
									AND (FS.fcSiiestado		in (1,2) or (FS.fcSiiestado=3 AND fcSiiCodErr = 3000 ))
			INNER JOIN (SELECT MAX(f3.fcSiiNumEnvio) maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha) mes,YEAR(facFecha) anyo
						FROM dbo.facSii f3 
						INNER JOIN dbo.facturas ON facCtrCod	= fcSiiFacCtrCod 
												AND facPerCod	= fcSiiFacPerCod 
												AND facCod		= fcSiiFacCod 
												AND facVersion	= fcSiiFacVersion 						
						group by fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,MONTH(facFecha),YEAR(facFecha)) T	ON T.fcSiiFacCod		= FS.fcSiiFacCod	
																															   AND T.fcSiiFacPerCod		= FS.fcSiiFacPerCod	
																															   AND T.fcSiiFacCtrCod		= FS.fcSiiFacCtrCod	
																															   AND T.fcSiiFacVersion	= FS.fcSiiFacVersion
																															   AND T.maxFcSiiNumEnvio-1	= FS.fcSiiNumEnvio) T*/

	
/*

--34752
select * from vNumEnvioMaxFacSii
where mes=4
and anyo = 2020
ORDER BY fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion

--34752
select fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,COUNT(maxFcSiiNumEnvio)
from vNumEnvioMaxFacSii
where mes=4
and anyo = 2020
GROUP BY fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion
HAVING COUNT(maxFcSiiNumEnvio) = 1
ORDER BY fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion

--3
select * 
from vNumEnvioMaxFacSii
where mes=4
and anyo = 2020
and fcSiiFacCtrCod	= 59894
AND fcSiiFacPerCod	= '201904'
AND fcSiiFacCod		= 1
AND fcSiiFacVersion	= 2

--14
select * 
from vNumEnvioMaxFacSii
where mes=4
and anyo = 2020
and fcSiiFacCtrCod	= 50171
AND fcSiiFacPerCod		= '000004'
AND fcSiiFacCod		= 1
AND fcSiiFacVersion	= 1



declare @fechaD datetime = N'01/04/2020',
		@fechaH datetime = N'30/04/2020 23:59:59';

--34752
select count(*) facturasAbril
from(
select facCod, facPerCod, facCtrCod, facVersion 
from facturas
where facFecha>=@fechaD and facFecha <=@fechaH
group by facCod, facPerCod, facCtrCod, facVersion ) t

CREATE UNIQUE CLUSTERED INDEX idx_vNumEnvioMaxFacSii_1 ON dbo.vNumEnvioMaxFacSii(maxFcSiiNumEnvio,fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion);
CREATE NONCLUSTERED INDEX idx_vNumEnvioMaxFacSii_2     ON dbo.vNumEnvioMaxFacSii(fcSiiFacCod,fcSiiFacPerCod,fcSiiFacCtrCod,fcSiiFacVersion,maxFcSiiNumEnvio,mes,anyo);

*/
GO


