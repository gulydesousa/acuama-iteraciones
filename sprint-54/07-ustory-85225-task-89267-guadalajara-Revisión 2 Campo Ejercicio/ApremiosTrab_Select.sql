CREATE PROCEDURE [dbo].[ApremiosTrab_Select] 
@aptFacCod SMALLINT = NULL,
@aptFacPerCod VARCHAR(6) = NULL,
@aptFacCtrCod INT = NULL,
@aptFacVersion SMALLINT = NULL,
@aptUsrCod VARCHAR(10) = NULL,
@aptTipo SMALLINT = NULL

AS 
	SET NOCOUNT ON; 
SELECT 
	aptFacCod, aptFacPerCod, aptFacCtrCod, aptFacVersion, aptUsrCod,
	facfecha,
	(CASE WHEN ctrTitNom IS NULL THEN clinom ELSE ctrTitNom END) AS titularNombre,
	ISNULL(ftfImporte, 0) AS importe,
	(SELECT TOP 1 aprNumero FROM apremios WHERE aprFacPerCod = facPerCod AND aprFacCtrCod = facCtrCod AND aprFacCod = facCod AND aprFacVersion = facVersion) AS numeroGeneracion,
	facSerCod
FROM apremiosTrab
	INNER JOIN facturas ON aptFacCod=facCod AND aptFacPerCod=facPerCod  AND aptFacCtrCod=facCtrCod AND aptFacVersion=facVersion
	INNER JOIN contratos ON ctrcod = facCtrCod AND ctrversion = facCtrVersion
	INNER JOIN clientes ON clicod = ctrTitCod
	LEFT JOIN fFacturas_TotalFacturado(NULL, 0, NULL) ON ftfFacCod=facCod AND ftfFacPerCod=facPerCod  AND ftfFacCtrCod=facCtrCod AND ftfFacVersion=facVersion
WHERE 
	(aptFacCod = @aptFacCod OR @aptFacCod IS NULL) AND 
	(aptFacPerCod = @aptFacPerCod OR @aptFacPerCod IS NULL) AND
	(aptFacCtrCod = @aptFacCtrCod OR @aptFacCtrCod IS NULL) AND
	(aptFacVersion = @aptFacVersion OR @aptFacVersion IS NULL) AND
	(aptUsrCod = @aptUsrCod OR @aptUsrCod IS NULL) AND
	(aptTipo = @aptTipo OR @aptTipo IS NULL)
				 
ORDER BY aptFacCtrCod, aptFacPerCod, aptFacCod, aptFacVersion, aptTipo



GO




