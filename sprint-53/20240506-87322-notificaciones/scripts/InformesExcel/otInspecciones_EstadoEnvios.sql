/*
INSERT INTO dbo.ExcelConsultas
VALUES ('000/041',	'Inspecciones: Envios', 'Para comprobar el estado de los envios de las inspecciones', 0, '[InformesExcel].[otInspecciones_EstadoEnvios]', '001', 'Permite comprobar el estado actual de la inspeccion y su envío', NULL, NULL, NULL, NULL);

INSERT INTO ExcelPerfil
VALUES('000/041', 'root', 6, NULL)

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

ALTER PROCEDURE [InformesExcel].[otInspecciones_EstadoEnvios]
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
	
	SELECT [Ref. Correos] = E.notificacionid
	, [Contrato Notificación] = E.contrato
	, [Inspección] = E.objectid
	, [OT Inspección] = E.ot_inspeccion
	, [Contrato General]  = E.ctrcod
	, [Estado] = CONCAT(E.EstadoId, ' - ', E.Estado)
	, [Estado Fecha] = E.EstadoFecha
	, [Final Plazo] = E.FinalPlazo
	, [Notificado] = E.NotificadoFecha
	--************************************
	, [BOE F.Envío] = E.fechaenvioboe
	, [BOE F.Publicación] = E.fechapubboe
	, [BOE Ref.Interna] = E.RefIntBOE
	, [BOE Número] = E.NumBOE
	, [Inspección Apta] = ISNULL(I.otdvValor, 'Compruebe la validez de los datos enviados en el csv de estados (correos)')
	FROM dbo.vOtInspeccionesNotificacionEdo_Melilla AS E
	LEFT JOIN  dbo.vOtInspeccionesAptas_Melilla AS I
	ON E.objectid = I.objectid AND E.contrato = I.ctrcod
	ORDER BY E.ot_inspeccion, IIF(E.ctrcod=E.contrato, 0, 1), E.contrato, E.FinalPlazo

GO
