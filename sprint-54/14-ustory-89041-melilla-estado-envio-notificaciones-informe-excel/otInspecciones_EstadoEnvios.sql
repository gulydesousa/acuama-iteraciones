/*
INSERT INTO dbo.ExcelConsultas
VALUES ('000/041',	'Inspecciones: Envios', 'Para comprobar el estado de los envios de las inspecciones', 1, '[InformesExcel].[otInspecciones_EstadoEnvios]', '001', 'Permite comprobar el estado actual de la inspeccion y su envío', NULL, NULL, NULL, NULL);

INSERT INTO ExcelPerfil
VALUES('000/041', 'root', 6, NULL)

--DELETE FROM  ExcelPerfil WHERE ExpCod='000/040'
--DELETE FROM dbo.ExcelConsultas WHERE ExcCod='000/040'
*/

/*
DECLARE @p_params NVARCHAR(MAX);
DECLARE @p_errId_out INT;
DECLARE @p_errMsg_out NVARCHAR(2048);

SET @p_params= '<NodoXML><LI><FecDesde>20230322</FecDesde><FecHasta></FecHasta></LI></NodoXML>'


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
	DECLARE @params TABLE (FecDesde DATE NULL, FecHasta DATE NULL, fInforme DATETIME);
	INSERT INTO @params
	SELECT  FecDesde = CASE WHEN M.Item.value('FecDesde[1]', 'DATE') = '19000101' THEN NULL ELSE M.Item.value('FecDesde[1]', 'DATE') END
			, FecHasta = CASE WHEN M.Item.value('FecHasta[1]', 'DATE') = '19000101' THEN NULL ELSE M.Item.value('FecHasta[1]', 'DATE') END
			, fInforme = GETDATE()
	FROM @xml.nodes('NodoXML/LI')AS M(Item);
	
	UPDATE @params SET FecHasta = DATEADD(DAY, 1, FecHasta)
	OUTPUT DELETED.*;
	

	--Esto lo hacemos así porque solo puede haber una emisión.
	--El estado de la entrega se repite para cada notificacion, 
	--lo cual conduce a resultados duplicados en el caso de emisiones duales (Titular, Representante)
	--Si se permitieran mas de una emision, es mas  complicado tracear el resultado de la in
	SELECT [Copia] = ROW_NUMBER() OVER(PARTITION BY I.objectid, I.ctrcod ORDER BY I.notificacionid)
	, [Inspección] = I.objectid
	, [OT Inspección] = I.otiNum
	, [Servicio] = I.servicio
	, [Contrato General] = I.CTRCOD_INSPECCION
	, [Contrato Abonado] = I.ctrcod
	--**************************************
	--Datos de la pegatina
	, [Dirección Postal] = ISNULL(N.FISDIR1, N.INMUEBLE)
	, [Tipo Destinatario] = CASE WHEN N.emisionID IS NULL THEN NULL 
								 WHEN emisionEstado='Emitir' THEN 'Titular' 
								 ELSE 'Representante' END
	, [Destinatario] = N.FISNOM
	--**************************************
	, [Inspección Apta] = I.Apta
	, [Fecha emisión] = NE.fecha
	, [Notificacion ID] = FORMAT(N.EmisionID, 'D4') + '-' + FORMAT(ISNULL(N.RN, 0), 'D6')
	, [Ref. Correos] = E.notificacionid
	, [Estado] = IIF(E.EstadoId IS NULL, NULL, CONCAT(E.EstadoId, ' - ', E.Estado))
	, [Estado Fecha] = E.EstadoFecha
	, [Final Plazo] = E.FinalPlazo
	, [Notificado] = E.NotificadoFecha
	--************************************
	, [BOE F.Envío] = E.fechaenvioboe
	, [BOE F.Publicación] = E.fechapubboe
	, [BOE Ref.Interna] = E.RefIntBOE
	, [BOE Número] = E.NumBOE
	FROM vOtInspecciones_Melilla AS I
	LEFT JOIN ReportingServices.TO039_EmisionNotificaciones_Notificaciones AS N
	ON I.objectid = N.objectid
	AND I.ctrcod = N.CONTRATO
	LEFT JOIN ReportingServices.TO039_EmisionNotificaciones_Emisiones AS NE ON N.emisionID= NE.emisionID
	LEFT JOIN dbo.vOtInspeccionesNotificacionEdo_Melilla AS E	
	ON E.objectid = N.objectid
	AND E.contrato = N.CONTRATO
	AND E.ot_inspeccion = N.otNum
	AND E.notificacionid = I.notificacionid



	ORDER BY I.objectid
			, IIF(I.CTRCOD_INSPECCION=I.ctrcod, 0, 1)
			, E.contrato
			, E.notificacionid
			, E.FinalPlazo;

GO


