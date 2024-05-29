INSERT INTO dbo.ExcelConsultas
VALUES ('000/041',	'Inspecciones Envios', 'Para comprobar el estado de los envios de las inspecciones', 0, '[InformesExcel].[otInspecciones_EstadoEnvios]', '001', 'Permite comprobar el estado actual de la inspeccion y su envío', NULL, NULL, NULL, NULL);

INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/041', 'direcc', 695, NULL)


INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/041', 'root', 695, NULL)




--DELETE FROM  ExcelPerfil WHERE ExpCod='000/041'
--DELETE FROM dbo.ExcelConsultas WHERE ExcCod='000/041'


SELECT * FROM dbo.ExcelConsultas WHERE ExcCod='000/041'
SELECT * FROM  ExcelPerfil WHERE ExpCod='000/041'


/*
DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI></LI></NodoXML>';


EXEC [InformesExcel].[otInspecciones_EstadoEnvios] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
*/