DECLARE @tecnica INT;
SELECT @tecnica = menuid FROM menu WHERE menutitulo_es='Técnica'

DECLARE @menuID INT;
SELECT @menuID = MAX(menuID) + 1 FROM menu;

--Insertar menu padre
DECLARE @notificaciones INT;
SELECT @notificaciones = menuid  FROM menu WHERE menupadre=@tecnica AND menutitulo_es = 'Notificaciones'


INSERT INTO dbo.ExcelConsultas
VALUES ('000/041',	'Inspecciones Envios', 'Para comprobar el estado de los envios de las inspecciones', 1, '[InformesExcel].[otInspecciones_EstadoEnvios]', '001', 'Permite comprobar el estado actual de la inspeccion y su envío', NULL, NULL, NULL, NULL);

INSERT INTO ExcelPerfil
VALUES('000/041', 'direcc', @notificaciones, NULL)
INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/041', 'root', @notificaciones, NULL)

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