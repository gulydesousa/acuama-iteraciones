
select * from  otInspeccionesNotificacionEdo_Melilla
 
WHERE
 
CASE
 
WHEN codigofinal IS NOT NULL THEN codigofinal
 
WHEN codigooficina IS NOT NULL THEN codigooficina
 
WHEN codigo2 IS NOT NULL THEN codigo2            
 
ELSE codigo1 -- Si ninguno de los anteriores tiene valor, se devuelve codigo1
 
END IN (2, 4, 5, 7)
 
AND RefIntBOE IS NULL
 
 
select * from  votInspeccionesNotificacionEdo_Melilla WHERE ot_inspeccion IN (27930, 27931, 27932, 27933, 27936)
--*****************



select * from vOtInspecciones_Melilla vi where ctrcod in (select contrato from 

otInspeccionesNotificacionEdo_Melilla
 
WHERE
 
CASE
 
WHEN codigofinal IS NOT NULL THEN codigofinal
 
WHEN codigooficina IS NOT NULL THEN codigooficina
 
WHEN codigo2 IS NOT NULL THEN codigo2            
 
ELSE codigo1 -- Si ninguno de los anteriores tiene valor, se devuelve codigo1
 
END IN (2, 4, 5, 7)
 
AND RefIntBOE IS NULL

)