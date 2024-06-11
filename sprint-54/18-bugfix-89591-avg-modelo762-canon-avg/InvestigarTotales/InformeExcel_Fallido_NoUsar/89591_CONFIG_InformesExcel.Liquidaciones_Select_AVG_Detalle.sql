--DELETE FROM ExcelPerfil WHERE ExPCod='010/020'
--DELETE FROM ExcelConsultas WHERE ExcCod='010/020'

DECLARE @codigo VARCHAR(10)= '010/020';

INSERT INTO dbo.ExcelConsultas
VALUES (@codigo,	'AVG Modelo 762', 'Modelo 762: Lineas de liquidaciones (F)', 1, '[InformesExcel].[Liquidaciones_Select_AVG_Detalle]', 'CSV', 'Lineas de facturas que se usan para completar el modelo 762 (Registro ''F'')', NULL, NULL, NULL, NULL);

--***************
--FACTURACION (4)
INSERT INTO ExcelPerfil --Nosotros
VALUES(@codigo, 'root', 4, NULL)

INSERT INTO ExcelPerfil --Margari
VALUES(@codigo, 'jefAdmon', 4, NULL)

SELECT * FROM ExcelConsultas WHERE ExcCod=@codigo

