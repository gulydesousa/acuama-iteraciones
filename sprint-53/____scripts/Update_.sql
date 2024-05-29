SELECT * 
--UPDATE V SET otivDescParaCartas=otivDesc
FROM otInspeccionesValidaciones AS V
ORDER BY otivServicioCod, otivOrden


SELECT * 
--UPDATE V SET otivDesc=otivColumna
FROM otInspeccionesValidaciones AS V
ORDER BY otivServicioCod, otivOrden


SELECT * 
--UPDATE V SET otivDesc='plantabaja//sepradogas'
FROM otInspeccionesValidaciones AS V
WHERE otivColumna='plantabaja'

INSERT INTO otInspeccionesValidaciones
SELECT 'sepradogas', otivServicioCod, otivCritica, otivReqReglamentoCTE, otivOrden, otivDesc, otivDescParaCartas
--UPDATE V SET otivDesc='plantabaja//sepradogas'
FROM otInspeccionesValidaciones AS V
WHERE otivColumna='plantabaja'


