--facEstado: cFacturaBO.EEstados
--CobroBloqueado = 6
--SinDeterminar = 0

SELECT facEstado, * 
--UPDATE F SET facEstado=0
FROM facturas AS F
WHERE facCod = 1
AND facCtrCod='109901757' 
AND facPerCod IN ('202304', '202305')
AND facVersion=2
AND facFechaRectif IS NULL 
AND facEstado<>0 




/*
--ESTADOS DE FACTURA NO EXISTEN EN UNA TABLA MAESTRA
//C:\Sacyr\workspace-git\Sacyr.Acuama\emmasa\AppBO\Facturacion\cFacturaBO.cs
public enum EEstados : short
{
    SinDeterminar = 0,
	Agrupada = 4, //FACTURA
	Traspasada = 5, //FACTURA
	CobroBloqueado = 6, //FACTURA
	Albaran = 7, //PREFACTURA
	CobroDetenidoSJ = 8,
	Prescrita = 9, //FACTURA
    CobroDetenidoCorte = 10, //FACTURA
	
	/// Cuando la factura está en expediente de impago y se solicita paso a jurídica, SIN quedar bloqueado el cobro
    ImpagoASJ = 11, // FACTURA
	
	/// Factura en cobro detenido por estar el contador en verificación por contador patrón
    CobroDetenidoPatron = 12 // FACTURA
}

*/

https://syrena.sacyr.com/browse/SYR-305848