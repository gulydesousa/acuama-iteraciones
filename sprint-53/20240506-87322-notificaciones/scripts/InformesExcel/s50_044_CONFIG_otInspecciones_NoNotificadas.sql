DECLARE @tecnica INT;
SELECT @tecnica = menuid FROM menu WHERE menutitulo_es='Técnica'

DECLARE @menuID INT;
SELECT @menuID = MAX(menuID) + 1 FROM menu;

--Insertar menu padre
DECLARE @notificaciones INT;
SELECT @notificaciones = menuid  FROM menu WHERE menupadre=@tecnica AND menutitulo_es = 'Notificaciones'



INSERT INTO dbo.ExcelConsultas
VALUES ('000/044',	'Estado de notificaciones','Para comprobar el estado de las notificaciones de inspecciones de Melilla',	0,	'[InformesExcel].[otInspecciones_NoNotificadas]',	'001',	'Para comprobar el esado de las notificaciones de inspecciones cargadas',	NULL,	NULL,	NULL,	NULL)
INSERT INTO ExcelPerfil
VALUES('000/044', 'root', @notificaciones, NULL)

INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/044', 'direcc', @notificaciones, NULL)
SELECT * FROM ExcelPerfil WHERE ExpCod='000/044'
SELECT * FROM dbo.ExcelConsultas WHERE ExcCod='000/044'

--DELETE FROM  ExcelPerfil WHERE ExpCod='000/044'
--DELETE FROM dbo.ExcelConsultas WHERE ExcCod='000/044'

/*

DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><Fecha></Fecha></LI></NodoXML>';


EXEC [InformesExcel].[otInspecciones_NoNotificadas] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;

*/