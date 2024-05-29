/*


INSERT INTO dbo.ExcelConsultas
VALUES ('000/041',	'Inspecciones: Envios', 'Para comprobar el estado de los envios de las inspecciones', 0, '[InformesExcel].[otInspecciones_EstadoEnvios]', '001', 'Permite comprobar el estado actual de la inspeccion y su envío', NULL, NULL, NULL, NULL);

INSERT INTO ExcelPerfil
VALUES('000/041', 'root', 6, NULL)

INSERT INTO ExcelPerfil --NOTIFICACIONES
VALUES('000/041', 'direcc', 695, NULL)

--DELETE FROM  ExcelPerfil WHERE ExpCod='000/040'
--DELETE FROM dbo.ExcelConsultas WHERE ExcCod='000/040'


*/


/*
DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI></LI></NodoXML>';


EXEC [InformesExcel].[otInspecciones_EstadoEnvios] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
*/

CREATE PROCEDURE [InformesExcel].[otInspecciones_EstadoEnvios]
	@p_params NVARCHAR(MAX),
	@p_errId_out INT OUTPUT, 
	@p_errMsg_out NVARCHAR(2048) OUTPUT
AS

	SET NOCOUNT ON;   


	--DataTable[1]:  Parametros
	DECLARE @xml AS XML = @p_params;
	
	DECLARE @params TABLE (fInforme DATETIME);

	INSERT INTO @params
	OUTPUT INSERTED.*	
	SELECT fInforme = GETDATE()
	FROM @xml.nodes('NodoXML/LI')AS M(Item);


	SELECT E.*, otdvValor
	FROM dbo.vOtInspeccionesAptas_Melilla AS I
	INNER JOIN dbo.otInspecciones_Melilla AS II
	ON I.objectid = II.objectid
	INNER JOIN dbo.vOtInspeccionesNotificacionEdo_Melilla AS E
	ON E.ctrcod = II.ctrcod AND E.otinum = II.otinum
	ORDER BY FinalPlazo

GO


