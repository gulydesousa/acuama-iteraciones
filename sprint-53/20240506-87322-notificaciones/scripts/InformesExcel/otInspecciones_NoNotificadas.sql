/*

INSERT INTO dbo.ExcelConsultas
('000/015',	'Estado de: notificaciones','Para comprobar el estado de las notificaciones de inspecciones de Melilla',	0,	'[InformesExcel].[otInspecciones_NoNotificadas]',	'001',	'Para comprobar el esado de las notificaciones de inspecciones cargadas',	NULL,	NULL,	NULL,	NULL)


insert into [dbo].[ExcelPerfil]
values('000/015','direcc',6,NULL)

insert into [dbo].[ExcelPerfil]
values('000/015','root',6,NULL)

*/


--DECLARE @p_params NVARCHAR(MAX);
--DECLARE @p_errId_out INT;
--DECLARE @p_errMsg_out NVARCHAR(2048);

--SET @p_params= '<NodoXML></NodoXML>';

--EXEC [InformesExcel].[otInspecciones_NoNotificadas] @p_params,  @p_errId_out OUTPUT, @p_errMsg_out OUTPUT;
--drop PROCEDURE [InformesExcel].[otInspecciones_NoNotificadas]

ALTER PROCEDURE [InformesExcel].[otInspecciones_NoNotificadas]
	@p_params NVARCHAR(MAX),
	@p_errId_out INT OUTPUT, 
	@p_errMsg_out NVARCHAR(2048) OUTPUT
AS
	SET NOCOUNT ON;  
	
	BEGIN TRY

	--DataTable[1]:  Parametros	
	DECLARE @xml AS XML = @p_params;
	
	DECLARE @params TABLE (fInforme DATETIME);

	INSERT INTO @params
	OUTPUT INSERTED.*	
	SELECT fInforme = GETDATE()
	FROM @xml.nodes('NodoXML')AS M(Item);
	
	--********************
	--DataTable[2]:  Grupos
	--SELECT Grupo = 'Notificaciones BOE';
	--********************

	--Necesitamos poder sacar listado con estos datos: NÚM DE INSPECCIÓN, FECHA DE INSPECCIÓN, CONTRATO, SUJETO PASIVO, DIRECCIÓN DE OBJETO TRIBUTARIO, CONTADOR, CUMPLE NORMATIVA (si/no), CAMBIO CONTADOR (apto/no apto).

    --Además, debemos tener columnas y posibilidad de actualización masiva de estas, serían FECHA ENVÍO BOE, FECHA PUBLICADO BOE, NÚM BOE.
	
	--, RefIntBOE as Referencia_BOE, NumBOE
		

		SELECT CTRCOD_INSPECCION as codigoInspecion,
		vi.fecha_y_hora_de_entrega_efectiv as FechaInspeccion,
		vi.ctrcod
		, ctrTitNom
		,inmDireccion
		,conNumSerie
		, Apta as  CUMPLENORMATIVAsino
		,UltimoEstadoId
		,UltimoEstado
		,fechaenvioboe,	fechapubboe , RefIntBOE as Referencia_BOE, NumBOE		
 FROM vOtInspecciones_Melilla vi
 inner join dbo.contratos c on c.ctrcod = vi.ctrcod and ( c.ctrversion = (select max(cc.ctrcod) from dbo.contratos cc where cc.ctrcod = c.ctrcod))
 inner join dbo.inmuebles on inmcod =c.ctrinmcod
 inner join dbo.fContratos_ContadoresInstalados(null) ci on ci.ctcCtr = c.ctrcod
 Where UltimoEstadoId in(0,2,4,5,6,7,9) order by vi.ctrcod, apta 

  	
END TRY
	

BEGIN CATCH


	SELECT  @p_errId_out = ERROR_NUMBER()
	     ,  @p_errMsg_out= ERROR_MESSAGE();
END CATCH

GO


