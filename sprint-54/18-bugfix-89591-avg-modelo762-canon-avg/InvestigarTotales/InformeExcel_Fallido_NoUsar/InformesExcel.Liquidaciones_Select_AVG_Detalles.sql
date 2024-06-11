/*
--DELETE FROM ExcelPerfil WHERE ExPCod='010/020'
--DELETE FROM ExcelConsultas WHERE ExcCod='010/020'

DECLARE @codigo VARCHAR(10)= '010/020';

INSERT INTO dbo.ExcelConsultas
VALUES (@codigo,	'AVG Modelo 762', 'Modelo 762: Lineas de liquidaciones (F)', 1, '[InformesExcel].[Liquidaciones_Select_AVG_Detalle]', 'CSV', 'Lineas de facturas que se usan para completar el modelo 762 (Registro ''F'')', NULL, NULL, NULL, NULL);


--***************
--FACTURACION (4)
INSERT INTO ExcelPerfil --Nosotros
VALUES(@codigo, 'root', 4, NULL)

INSERT INTO ExcelPerfil --Margari
VALUES(@codigo, 'jefAdmon', 4, NULL)

SELECT * FROM ExcelConsultas WHERE ExcCod=@codigo

*/

/*

DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><FecDesde>20230101</FecDesde><FecHasta>20231231</FecHasta></LI></NodoXML>';

EXEC [InformesExcel].[Liquidaciones_Select_AVG_Detalle] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
*/


CREATE PROCEDURE [InformesExcel].[Liquidaciones_Select_AVG_Detalle]
	@p_params NVARCHAR(MAX),
	@p_errId_out INT OUTPUT, 
	@p_errMsg_out NVARCHAR(2048) OUTPUT
AS
	SET NOCOUNT ON;   




	--DataTable[0]:  Parametros
	DECLARE @xml AS XML = @p_params;
	DECLARE @params TABLE (FecDesde DATE NULL, fInforme DATETIME, FecHasta DATE NULL);

	INSERT INTO @params
	OUTPUT INSERTED.*
	SELECT  FecDesde = CASE WHEN M.Item.value('FecDesde[1]', 'DATE') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecDesde[1]', 'DATE') END
		  , fInforme     = GETDATE()
		  , FecHasta = CASE WHEN M.Item.value('FecHasta[1]', 'DATE') = '19000101' THEN NULL 
						   ELSE M.Item.value('FecHasta[1]', 'DATE') END
	FROM @xml.nodes('NodoXML/LI')AS M(Item);
	

	--DataTable[1]:  GRUPO	
	SELECT Grupo='Tipo F';

	DECLARE   @fechaFacturaD AS DATETIME= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
			, @fechaFacturaH AS DATETIME= DATEFROMPARTS(YEAR(GETDATE()), 12, 31)
			, @fechaLiquidacionD AS DATETIME
			, @fechaLiquidacionH AS DATETIME
			, @periodoD AS VARCHAR(6)
			, @periodoH AS VARCHAR(6)
			, @zonaD AS VARCHAR(4)
			, @zonaH AS VARCHAR(4)
			, @contrato AS INT
			, @version AS INT;

	SELECT @fechaFacturaD=FecDesde
		 , @fechaFacturaH=FecHasta FROM @params 
	WHERE FecDesde IS NOT NULL 
	  AND FecHasta IS NOT NULL 
	  --Evitamos pasarnos de días
	  AND DATEDIFF(DAY,FecDesde, FecHasta) <= 400;



	--Este SP no funciona correctamente si lo pasas sin filtro de contratos
	EXEC [dbo].[Liquidaciones_Select_AVG_Detalle] 
	@fechaFacturaD, @fechaFacturaH,
	@fechaLiquidacionD, @fechaLiquidacionH, 
	@periodoD, @periodoH,
	@zonaD, @zonaH,
	@contrato, @version;

GO


