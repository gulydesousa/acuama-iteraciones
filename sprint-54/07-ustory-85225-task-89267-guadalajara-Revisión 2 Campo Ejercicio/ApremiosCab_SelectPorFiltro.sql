ALTER PROCEDURE [dbo].[ApremiosCab_SelectPorFiltro] 
@filtro varchar(500) = NULL
AS 
SET NOCOUNT ON; 
	
EXECUTE('SELECT aprNumero, aprFechaGeneracion, COUNT(aprNumero) apremiosTotal, SUM(ISNULL(ftfImporte, 0)) AS importesTotal
			     FROM apremios
				 INNER JOIN facturas ON aprFacVersion = facVersion AND aprFacPerCod = facPerCod AND aprFacCtrCod = facCtrCod AND facVersion = aprFacVersion 
				 LEFT JOIN fFacturas_TotalFacturado(NULL, 0, NULL) ON ftfFacCod=facCod AND ftfFacPerCod=facPerCod  AND ftfFacCtrCod=facCtrCod AND ftfFacVersion=facVersion
				 ' + @filtro + 
				 ' GROUP BY aprNumero, aprFechaGeneracion' +
				 ' ORDER BY aprNumero DESC, aprFechaGeneracion DESC'
	   )
GO


