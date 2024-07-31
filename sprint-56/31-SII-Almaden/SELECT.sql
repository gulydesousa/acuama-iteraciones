WITH C AS (

SELECT *, RN = ROW_NUMBER() OVER (PARTITION BY fcSiiFacCod, fcSiiFacPerCod, fcSiiFacCtrCod, fcSiiFacVersion ORDER BY fcSiiNumEnvio DESC)
FROM facSII
WHERE fcSiiFechaExpedicionFacturaEmisor>='20240101'
)

SELECT * FROM C WHERE RN=1 AND (fcSiiestado IS NULL OR fcSiiestado<>1 ) ORDER BY fcSiiImporteTotal


SELECT * FROM facsii WHERE fcSiiNumSerieFacturaEmisor='100-12-2410067'