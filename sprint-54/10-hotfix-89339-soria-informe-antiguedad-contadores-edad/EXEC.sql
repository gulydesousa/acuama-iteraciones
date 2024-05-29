DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><valor>12</valor><zonaD></zonaD><zonaH></zonaH></LI></NodoXML>';

EXEC [InformesExcel].[ContadoresxAntiguedad]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;

EXEC [InformesExcel].[ContadoresxAntiguedad_old]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;

--EXEC [InformesExcel].[ContadoresxAntiguedad_new]  @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;