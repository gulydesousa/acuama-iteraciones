IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_BASEURL'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_BASEURL',
'Url para conectar con Contazara',
2, 
'https://api.contazara.es',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_BASEURL';