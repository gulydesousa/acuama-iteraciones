INSERT INTO dbo.ExcelConsultas
VALUES ('000/043',	'Inspecciones Aptas', 'Para comprobar el estado de las inspecciones de Melilla', 0, '[InformesExcel].[otInspecciones_ContratoGeneral_Melilla]', '000', 'Para comprobar el estado de las inspecciones cargadas.', NULL, NULL, NULL, NULL);

INSERT INTO ExcelPerfil
VALUES('000/043', 'root', 695, NULL)


INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/043', 'direcc', 695, NULL)

SELECT * FROM ExcelPerfil WHERE ExpCod='000/043'
SELECT * FROM dbo.ExcelConsultas WHERE ExcCod='000/043'

--DELETE FROM  ExcelPerfil WHERE ExpCod='000/043'
--DELETE FROM dbo.ExcelConsultas WHERE ExcCod='000/013'

/*

DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><Fecha></Fecha></LI></NodoXML>';


EXEC [InformesExcel].[otInspecciones_ContratoGeneral_Melilla] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;

*/