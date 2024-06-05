DECLARE @menuID INT;
DECLARE @menuPadre INT;
DECLARE @menuOrden INT;
DECLARE @menuURL VARCHAR(250) = '~/Almacen/TO041_OtInspeccionesFicheros.aspx';
SELECT 1 FROM menu WHERE menuurl = @menuURL
SELECT @menuID = MAX(menuid)+1 FROM menu;
--DELETE FROM menu WHERE menuurl = @menuURL
SELECT @menuPadre= menupadre , @menuOrden = menuOrden +1 
FROM menu WHERE menuurl LIKE '%TO022%';

IF(NOT EXISTS (SELECT 1 FROM menu WHERE menuurl = @menuURL))
INSERT INTO menu VALUES(
@menuID, 
@menuPadre,
'Ficheros OT Inspecciones',
'Carga masiva de los ficheros de OT de Inspección',
NULL,
@menuURL,
'~/Almacen/Css/otInspeccionesMasivas.css',
NULL, 
NULL,
@menuOrden,
1, 
1)


SELECT *
--DELETE
FROM menu WHERE menuurl = @menuURL



