-- =============================================
-- Author:		ACUAMA
-- Create date: 02/10/12
-- =============================================
ALTER PROCEDURE [dbo].[ApremiosCab_Select]
	 @aprNumero INT = NULL
	,@aprFechaGeneracion DATETIME = NULL
AS
SET NOCOUNT OFF;

SELECT aprNumero, aprFechaGeneracion, COUNT(aprNumero) apremiosTotal, SUM(ISNULL(ftfImporte, 0)) AS importesTotal 
	   FROM apremios
	   INNER JOIN facturas ON aprFacVersion = facVersion AND aprFacPerCod = facPerCod AND aprFacCtrCod = facCtrCod AND facVersion = aprFacVersion 
	   LEFT JOIN fFacturas_TotalFacturado(NULL, 0, NULL) ON ftfFacCod=facCod AND ftfFacPerCod=facPerCod  AND ftfFacCtrCod=facCtrCod AND ftfFacVersion=facVersion
	   WHERE (@aprNumero IS NULL OR @aprNumero = aprNumero) AND 
			 (@aprFechaGeneracion IS NULL OR CONVERT(VARCHAR, @aprFechaGeneracion, 120) = CONVERT(VARCHAR, aprFechaGeneracion, 120))
GROUP BY aprNumero, aprFechaGeneracion
ORDER BY aprNumero DESC, aprFechaGeneracion DESC;
GO


