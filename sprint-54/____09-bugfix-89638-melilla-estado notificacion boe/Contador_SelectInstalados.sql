/*
	DECLARE 
	@incidenciaCambioContador BIT = NULL, --True = Obtiene tambi�n los que tengan la marca "cambio de contador" en la incidencia de lectura. False � NULL obtiene todos
	@codigo INT = NULL,
	@inciLecLectorD VARCHAR(2) = NULL,
	@inciLecLectorH VARCHAR(2) = NULL,
	@inciLecInspD VARCHAR(2) = NULL,
	@inciLecInspH VARCHAR(2) = NULL,
	@contratoD INT = NULL,
	@contratoH INT = NULL,
	@contadorD VARCHAR(14) = NULL, --N�mero de serie
	@contadorH VARCHAR(14) = NULL,
	@fechaCompraD DATETIME = NULL,
	@fechaCompraH DATETIME = NULL,
	@fechaInstalacionD DATETIME = NULL,
	@fechaInstalacionH DATETIME = NULL,
	@SinOTAbiertas BIT = NULL
	--Mejoras Generaci�n masiva de ordenes de trabajo Acuama
  , @zonaD VARCHAR(4) = NULL
  , @zonaH VARCHAR(4) = NULL
  , @ruta1 VARCHAR(10) = NULL
  , @ruta2 VARCHAR(10) = NULL
  , @ruta3 VARCHAR(10) = NULL
  , @ruta4 VARCHAR(10) = NULL
  , @ruta5 VARCHAR(10) = NULL
  , @ruta6 VARCHAR(10) = NULL

  , @ruta1H VARCHAR(10) = NULL
  , @ruta2H VARCHAR(10) = NULL
  , @ruta3H VARCHAR(10) = NULL
  , @ruta4H VARCHAR(10) = NULL
  , @ruta5H VARCHAR(10) = NULL
  , @ruta6H VARCHAR(10) = NULL
  , @SoloPendientes BIT = NULL
  , @SoloInspeccionesAptas BIT = NULL
   
  , @diasPlazoD INT = 0
  , @diasPlazoH INT = 99


  EXEC [dbo].[Contador_SelectInstalados] @incidenciaCambioContador, @codigo, @inciLecLectorD, @inciLecLectorH, @inciLecInspD, @inciLecInspH, @contratoD, @contratoH, @contadorD, @contadorH, @fechaCompraD
										, @fechaCompraH, @fechaInstalacionD, @fechaInstalacionH, @SinOTAbiertas, @zonaD, @zonaH, @ruta1, @ruta2, @ruta3, @ruta4, @ruta5, @ruta6, @ruta1H, @ruta2H, @ruta3H, @ruta4H, @ruta5H, @ruta6H
										, @SoloPendientes, @SoloInspeccionesAptas, @diasPlazoD, @diasPlazoH;
*/

ALTER PROCEDURE [dbo].[Contador_SelectInstalados] 
	@incidenciaCambioContador BIT = NULL, --True = Obtiene tambi�n los que tengan la marca "cambio de contador" en la incidencia de lectura. False � NULL obtiene todos
	@codigo INT = NULL,
	@inciLecLectorD VARCHAR(2) = NULL,
	@inciLecLectorH VARCHAR(2) = NULL,
	@inciLecInspD VARCHAR(2) = NULL,
	@inciLecInspH VARCHAR(2) = NULL,
	@contratoD INT = NULL,
	@contratoH INT = NULL,
	@contadorD VARCHAR(14) = NULL, --N�mero de serie
	@contadorH VARCHAR(14) = NULL,
	@fechaCompraD DATETIME = NULL,
	@fechaCompraH DATETIME = NULL,
	@fechaInstalacionD DATETIME = NULL,
	@fechaInstalacionH DATETIME = NULL,
	@SinOTAbiertas BIT = NULL
	--Mejoras Generaci�n masiva de ordenes de trabajo Acuama
  , @zonaD VARCHAR(4) = NULL
  , @zonaH VARCHAR(4) = NULL
  , @ruta1 VARCHAR(10) = NULL
  , @ruta2 VARCHAR(10) = NULL
  , @ruta3 VARCHAR(10) = NULL
  , @ruta4 VARCHAR(10) = NULL
  , @ruta5 VARCHAR(10) = NULL
  , @ruta6 VARCHAR(10) = NULL

  , @ruta1H VARCHAR(10) = NULL
  , @ruta2H VARCHAR(10) = NULL
  , @ruta3H VARCHAR(10) = NULL
  , @ruta4H VARCHAR(10) = NULL
  , @ruta5H VARCHAR(10) = NULL
  , @ruta6H VARCHAR(10) = NULL
  , @SoloPendientes BIT = NULL
  , @SoloInspeccionesAptas BIT = NULL
  
  , @diasPlazoD INT = NULL
  , @diasPlazoH INT = NULL  

AS
SET NOCOUNT ON;

--**************************************************
--Generar OTs cambio de contador de inspecciones notificadas
DECLARE @SoloConPlazoNotificacion BIT = IIF(COALESCE(@diasPlazoD, @diasPlazoH) IS NOT NULL, 1, 0);

DECLARE @NotificadasEnPlazo AS TABLE(
RefCorreos INT,
objectid INT, 
CtrGeneral INT,	
CtrAbonado	INT,
DIAS INT,
EstadoFecha	DATE,
FinalPlazo	DATE,
Estado	VARCHAR(25),
NotificadoFecha DATE);

IF(@SoloConPlazoNotificacion = 1)
BEGIN
	INSERT INTO @NotificadasEnPlazo
	EXEC otInspeccionesNotificacionEdo_Melilla_ObtenerNotificadas @diasPlazoD, @diasPlazoH;
END

--**** DEBUG  ************
--SELECT [@SoloConPlazoNotificacion] = @SoloConPlazoNotificacion,  * FROM @NotificadasEnPlazo;
--**************************************************

SELECT	@ruta1=TRIM(@ruta1), @ruta1H=TRIM(@ruta1H),
		@ruta2=TRIM(@ruta2), @ruta2H=TRIM(@ruta2H),
		@ruta3=TRIM(@ruta3), @ruta3H=TRIM(@ruta3H),
		@ruta4=TRIM(@ruta4), @ruta4H=TRIM(@ruta4H),
		@ruta5=TRIM(@ruta5), @ruta5H=TRIM(@ruta5H),
		@ruta6=TRIM(@ruta6), @ruta6H=TRIM(@ruta6H);


WITH APTAS AS (
SELECT DISTINCT ctrcod AS iAptaCtrCod
FROM vOtInspecciones_Melilla  AS V
WHERE V.[Apta] IS NOT NULL 
AND V.Apta <> 'NO'
AND ([CONTRATO ABONADO] IS NULL OR  [CONTRATO ABONADO]=[CTRCOD_INSPECCION])
AND RN=1)

	
SELECT     --Datos contador
		   c1.conNumSerie 
		  ,conMcnCod
		  ,conClcCod
		  ,conFecReg
		  ,conComFec
		  ,conComPro
		  ,conHomFec
		  ,conHomRef
		  ,conHomPro
		  ,c1.conDiametro
		  ,[conMdlCod]
          ,[conEqpTipoCod] 
          ,[conTtzCod] 
          ,[conConTipoCod] 
          ,[conAlmCod] 
          ,[conNumRuedas] 
          ,[conCaudal]
          ,[conAnyoFab] 
          ,[conFecPrimIns] 
          ,[conFecFinGar] 
          ,[conFecRev] 
          ,[conFecPreRen] 
          ,[conPropCod]
          ,[conEstadoCod]
		  ,conID
		  ,c1.[conTeleLectura]
		  --Datos de instalaci�n
		  ,ctcCtr
		  ,ctcFec --Fecha de instalaci�n
          ,ctcLec --Lectura de instalaci�n
		  ,ctrTitCod --Cliente
		  --******************************
FROM contador
INNER JOIN fContratos_ContadoresInstalados(NULL) c1 ON ctcCon = conID /*Saca los registros que tengan una operaci�n I y no tengan luego una R*/
INNER JOIN dbo.contratos AS C ON 
			ctrCod = ctcCtr AND
			ctrVersion = (SELECT MAX(ctrVersion) FROM contratos cSub WHERE cSub.ctrCod = c.ctrCod)
LEFT JOIN dbo.facturas AS F ON 
						 facCtrCod = ctcCtr AND
					     facFechaRectif IS NULL AND --�ltima versi�n de la factura
					     facZonCod = ctrzoncod AND
						 facPerCod = (SELECT zonPerCod FROM zonas where zoncod = facZonCod) --�ltimo periodo facturado
LEFT JOIN APTAS AS A 
ON A.iAptaCtrCod=C.ctrcod
--***********************************
LEFT JOIN @NotificadasEnPlazo AS N
ON N.CtrAbonado = C.ctrcod 
WHERE (
		  (@codigo IS NULL OR conId = @codigo) AND
		  (@inciLecLectorD IS NULL OR @inciLecLectorD <= facLecInlCod) AND
		  (@inciLecLectorH IS NULL OR @inciLecLectorH >= facLecInlCod) AND
		  (@inciLecInspD IS NULL OR @inciLecInspD <= facInsInlCod) AND
		  (@inciLecInspH IS NULL OR @inciLecInspH >= facInsInlCod) AND
		  (@contratoD IS NULL OR @contratoD <= ctcCtr) AND
		  (@contratoH IS NULL OR @contratoH >= ctcCtr) AND
		  (@fechaCompraD IS NULL OR @fechaCompraD <= conComFec) AND
		  (@fechaCompraH IS NULL OR @fechaCompraH >= conComFec) AND
		  (@fechaInstalacionD IS NULL OR @fechaInstalacionD <= ctcFec) AND
		  (@fechaInstalacionH IS NULL OR @fechaInstalacionH >= ctcFec) AND
		  (@contadorD IS NULL OR @contadorD <= c1.conNumSerie) AND
		  (@contadorH IS NULL OR @contadorH >= c1.conNumSerie) AND
		  --*************************
		  --Mejoras Generaci�n masiva de ordenes de trabajo Acuama
		  (@zonaD IS NULL OR F.facZonCod>=@zonaD ) AND
		  (@zonaH IS NULL OR F.facZonCod<=@zonaH ) AND
		  		  
		  (@ruta1 IS NULL OR TRIM(C.ctrRuta1) >= @ruta1 ) AND
		  (@ruta2 IS NULL OR TRIM(C.ctrRuta2) >= @ruta2 ) AND
		  (@ruta3 IS NULL OR TRIM(C.ctrRuta3) >= @ruta3 ) AND
		  (@ruta4 IS NULL OR TRIM(C.ctrRuta4) >= @ruta4 ) AND
		  (@ruta5 IS NULL OR TRIM(C.ctrRuta5) >= @ruta5 ) AND
		  (@ruta6 IS NULL OR TRIM(C.ctrRuta6) >= @ruta6 ) AND

		  (@ruta1H IS NULL OR TRIM(C.ctrRuta1) <= @ruta1H ) AND
		  (@ruta2H IS NULL OR TRIM(C.ctrRuta2) <= @ruta2H ) AND
		  (@ruta3H IS NULL OR TRIM(C.ctrRuta3) <= @ruta3H ) AND
		  (@ruta4H IS NULL OR TRIM(C.ctrRuta4) <= @ruta4H ) AND
		  (@ruta5H IS NULL OR TRIM(C.ctrRuta5) <= @ruta5H ) AND
		  (@ruta6H IS NULL OR TRIM(C.ctrRuta6) <= @ruta6H ) AND
		  (@SoloInspeccionesAptas IS NULL OR @SoloInspeccionesAptas=0 OR A.iAptaCtrCod IS NOT NULL) AND

		  --***************************************************
		  (@SoloConPlazoNotificacion IS NULL OR @SoloConPlazoNotificacion=0 OR (@SoloConPlazoNotificacion= 1 AND objectid IS NOT NULL)) AND

		  --*************************		
		  (@SinOTAbiertas IS NULL OR @SinOTAbiertas = 0 OR (@SinOTAbiertas = 1 AND NOT EXISTS(SELECT otCtrCod 
																							  FROM dbo.ordenTrabajo AS OT
																							  WHERE OT.otCtrCod = C.ctrcod 
																							    AND OT.otottcod = (SELECT pgsvalor FROM parametros WHERE pgsclave = 'OT_TIPO_CC') 
																								AND OT.otfcierre IS NULL 
																								AND OT.otFecRechazo IS NULL)))
       ) 
      OR
      (
		(@incidenciaCambioContador = 1 AND EXISTS(SELECT inlcod FROM inciLec WHERE inlCod = facLecInlCod AND inlConCam = 1)) OR
	    (@incidenciaCambioContador = 1 AND EXISTS(SELECT inlcod FROM inciLec WHERE inlCod = facInsInlCod AND inlConCam = 1))
      )
ORDER BY conId

GO


