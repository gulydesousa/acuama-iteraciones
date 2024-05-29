--IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_TOKEN'))

--INSERT INTO parametros 
--OUTPUT INSERTED.*
--VALUES(
--'CONTAZARA_TOKEN',
--'Token para loguearnos con el API Contazara',
--2, 
--'',
--0,
--1, 
--0)

--ELSE
--SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_TOKEN';