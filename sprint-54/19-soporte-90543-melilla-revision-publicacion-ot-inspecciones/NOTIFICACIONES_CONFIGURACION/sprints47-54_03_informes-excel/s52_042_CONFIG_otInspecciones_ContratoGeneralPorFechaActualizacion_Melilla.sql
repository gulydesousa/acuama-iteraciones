DECLARE @tecnica INT;
SELECT @tecnica = menuid FROM menu WHERE menutitulo_es='Técnica'

DECLARE @menuID INT;
SELECT @menuID = MAX(menuID) + 1 FROM menu;

--Insertar menu padre
DECLARE @notificaciones INT;
SELECT @notificaciones = menuid  FROM menu WHERE menupadre=@tecnica AND menutitulo_es = 'Notificaciones'



INSERT INTO dbo.ExcelConsultas
VALUES ('000/042',	'Inspecciones Actualizadas', 'Inspecciones actualizadas por fecha', 3, '[InformesExcel].[otInspecciones_ContratoGeneralPorFechaActualizacion_Melilla]', '000', 'Para comprobar el estado de las inspecciones actualizadas', NULL, NULL, NULL, NULL);


INSERT INTO ExcelPerfil
VALUES('000/042', 'root', @notificaciones, NULL)

INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/042', 'direcc', @notificaciones, NULL)
--DELETE FROM  ExcelPerfil WHERE ExpCod='000/042'
--DELETE FROM dbo.ExcelConsultas WHERE ExcCod='000/042'

SELECT * FROM ExcelPerfil WHERE ExpCod='000/042'
SELECT * FROM dbo.ExcelConsultas WHERE ExcCod='000/042'

/*
DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><Fecha></Fecha></LI></NodoXML>';


EXEC [InformesExcel].[otInspecciones_ContratoGeneralPorFechaActualizacion_Melilla] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
*/