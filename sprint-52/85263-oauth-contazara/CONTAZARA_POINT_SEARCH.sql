IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_POINT_SEARCH'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_POINT_SEARCH',
'End Point para la búsqueda en el API Contazara',
2, 
'/meters/readings/search',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_POINT_SEARCH';