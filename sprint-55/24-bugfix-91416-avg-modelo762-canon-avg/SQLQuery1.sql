SELECT * FROM ExcelConsultas order by ExcDescLarga


DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><FecDesde>20140601</FecDesde><FecHasta>20240529</FecHasta></LI></NodoXML>';

EXEC [dbo].[Excel_ExcelConsultas.DeudaTipoFactura_EMMASA]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;


SELECT * FROM clientes WHERE clidociden='000000000'
SELECT * FROM clientes WHERE clicod=64420
SELECT ctrTitCod, ctrTitDocIden, * FROM contratos WHERE ctrTitDocIden='000000011'