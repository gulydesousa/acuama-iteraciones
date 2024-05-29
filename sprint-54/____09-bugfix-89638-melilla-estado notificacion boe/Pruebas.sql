exec Contador_SelectInstalados @codigo=NULL,@contadorD=NULL,@contadorH=NULL,@contratoD=NULL,@contratoH=NULL
,@diasPlazoD=40,@fechaCompraD=NULL,@fechaCompraH=NULL,@fechaInstalacionD=NULL,@fechaInstalacionH=NULL
,@incidenciaCambioContador=0,@inciLecInspD=NULL,@inciLecInspH=NULL,@inciLecLectorD=NULL
,@inciLecLectorH=NULL,@ruta1=NULL,@ruta1H=NULL,@ruta2=NULL,@ruta2H=NULL,@ruta3=NULL,@ruta3H=NULL,@ruta4=NULL,@ruta4H=NULL
,@ruta5=NULL,@ruta5H=NULL,@ruta6=NULL,@ruta6H=NULL
,@SinOTAbiertas=0
,@SoloInspeccionesAptas=0
,@zonaD=NULL,@zonaH=NULL


SELECT V.*, M.usuariocarga
FROM votInspecciones_Melilla AS V
INNER JOIN otInspecciones_Melilla  AS M
ON M.objectid = V.objectid
WHERE usuariocarga='mmorenol' 
AND V.MOCK=0