--SELECT * FROM ExcelConsultas WHERE ExcCod='321'
--SELECT * FROM ExcelPerfil WHERE ExPCod='321'
SELECT * FROM usuarios

INSERT INTO ExcelConsultas
VALUES('32100', 'Deuda AS', 'Deuda auditores Sevilla', 1, '[InformesExcel].[AuditoresSevillaDeudaTipoFactura]', '001', 'Totaliza la deuda por NIF del Titular del contrato.<br> Se espera que los totales coincidan con los del informe <b>"Deuda Tipo Factura"</b>-Excel_ExcelConsultas.DeudaTipoFactura_EMMASA-')

INSERT INTO ExcelPerfil
VALUES('32100', 'root', 3, NULL)

INSERT INTO ExcelPerfil
VALUES('32100', 'jefAdmon', 3, NULL)


SELECT * 
--DELETE
FROM ExcelConsultas WHERE ExcCod='321_AS'
SELECT * 
--DELETE
FROM ExcelPerfil WHERE ExPCod='321_AS'