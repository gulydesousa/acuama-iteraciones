TRUNCATE TABLE otInspeccionesValidaciones;
GO
--SELECT * FROM otInspeccionesValidaciones
--CONTADOR INDIVIDUAL
INSERT INTO otInspeccionesValidaciones
VALUES
('llavepaso', '2', '1', '1', '1', 'llavepaso', 'LLAVE DE PASO Y ARQUETA EN ACERA'), 
('tuberiaentrada', '2', '1', '1', '2', 'tuberiaentrada', 'TUBER�A DE ENTRADA AL EDIFICIO AL DESCUBIERTO EN UN TRAMO DE 35 CM EN EL QUE PRESENTA TOTAL HORIZONTALIDAD'), 
('arquetaconpuerta', '2', '0', '1', '3', 'arquetaconpuerta//arquetafachada//arquetanivelsuelo', 'TRAMO DE TUBER�A EN EL INTERIOR DE UN ARMARIO CON PUERTA DE 300X250X160 MM, INSTALADA EN FACHADA DEL EDIFICIO A UNA ALTURA DE ENTRE 0,90 M Y 1,5 M DESDE EL NIVEL DEL SUELO'), 
('arquetafachada', '2', '0', '1', '3', 'arquetaconpuerta//arquetafachada//arquetanivelsuelo', ''), 
('arquetanivelsuelo', '2', '0', '1', '3', 'arquetaconpuerta//arquetafachada//arquetanivelsuelo', ''), 
('juegollaves', '2', '1', '1', '4', 'juegollaves', 'JUEGO DE LLAVE DE ENTRADA Y SALIDA'), 
('valvularetencion', '2', '1', '0', '5', 'valvularetencion', 'V�LVULA DE RETENCI�N'), 
('roscacontadore', '2', '0', '0', '6', 'roscacontadore', 'DI�METRO ROSCA ENTRADA'), 
('roscacontadors', '2', '0', '0', '7', 'roscacontadors', 'DI�METRO ROSCA SALIDA'), 
('estadocontador', '2', '1', '0', '8', 'estadocontador', 'ESTADO DE CONSERVACI�N DE LA INSTALACI�N HIDR�ULICA (BUENO, MALO)');
GO

--BATERIAS
INSERT INTO otInspeccionesValidaciones
VALUES
('sepradogas','1','1','1','1','sepradogas//plantabaja','UBICACI�N EN PLANTA BAJA DEL EDIFICIO SEPARA DE DEPENDENCIAS DESTINADAS A GAS Y ELECTRICIDAD'),
('plantabaja','1','1','1','1','sepradogas//plantabaja',''),
('usocomun','1','0','1','2','usocomun//llavepasocerca','UBICACI�N EN ZONA DE F�CIL ACCESO Y USO COM�N DEL INMUEBLE, LO M�S CERCA POSIBLE DE LA LLAVE DE PASO DEL EDIFICIO'),
('llavepasocerca','1','0','1','2','usocomun//llavepasocerca',''),
('armarioid','1','0','1','3','armarioid//armario12','PUERTA DEL  ARMARIO IDENTIFICADA CON UNA O M�S HOJAS DEJANDO LIBRE AL ABRIRSE TODO EL ANCHO DEL MISMO'),
('armario12','1','0','1','3','armarioid//armario12',''),
('instestanca','1','1','1','4','instestanca','CUARTO DOTADO DE ILUMINACI�N EL�CTRICA ESTANCA '),
('desague','1','1','1','5','desague','PILETA DE GOTEO CON DESAG�E A LA ALCANTARILLA CON COTA ADECUADA'),
('aljibe','1','0','1','6','aljibe','EL ACCESO AL ALJIBE Y/O GRUPO DE PRESI�N SEPARADO DE LA PUERTA DE ACCESO AL CUARTO DE CONTADORES Y LA ZONA DE LECTURA'),
('armariounico','1','0','1','7','armariounico','CUARTO O ARMARIO DESTINADO EN EXCLUSIVA A INSTALACIONES DE CONTADORES DE AGUA'),
('llavescontadores','1','0','1','8','llavescontadores','CERRADURA DE LOS MODELOS ACEPTADOS POR EL SERVICIO'),
('tecnicas_bat_9','1','1','1','9','tecnicas_bat_9','BATER�A EN CIRCUITO CERRADO CON TRES TUBOS HORIZONTALES COMO M�XIMO'),
('tecnicas_bat_10','1','0','0','10','tecnicas_bat_10','FILA SUPERIOR DE CONTADORES M�XIMO A 1,60 M DE ALTURA DESDE EL SUELO O PUNTO DESDE EL QUE PISA EL LECTOR O INSPECTOR Y M�NIMO A 0,50 M METROS DEL TECHO'),
('tecnicas_bat_11','1','0','1','11','tecnicas_bat_11','FILA INFERIOR SITUADA COMO M�NIMO A 0,50 M DE ALTURA DESDE EL SUELO Y SEPARACI�N ENTRE FILAS DE 0,25 M. DISTANCIA DEL FONDO DE LA PARED 0,16 Y FILAS DE 3 M DE ANCHO'),
('tecnicas_bat_12','1','1','0','12','tecnicas_bat_12','LOS RAMALES PRESENTAN HORIZONTALIDAD EN UN TRAMO M�NIMO DE 35 CM'),
('juegollavesbat','1','1','1','13','juegollavesbat','LLAVES DE ENTRADA Y SALIDA EN CONTADORES'),
('tecnicas_bat_15','1','0','1','14','tecnicas_bat_15','LA BRIDA DE CONEXI�N A LA LLAVE DE ENTRADA A CONTADOR OVALADA, ORIENTADA DE FORMA QUE EL EJE MAYOR SEA PERPENDICULAR A LA PARED'),
('tecnicas_bat_16','1','1','1','15','tecnicas_bat_16','V�LVULA DE RETENCI�N INCORPORADA EN LOS CONTADORES DE SALIDA.'),
('tecnicas_bat_17','1','1','1','16','tecnicas_bat_17','LLAVES PROVISTAS DE MANGUITO CON JUNTA INCORPORADA, SIN CONTRARROSCAS'),
('tecnicas_bat_18','1','1','0','17','tecnicas_bat_18','BATER�A NO SIMULADA: LLAVE DE CORTE, BATER�A EN CIRCUITO CERRADO, LLAVE DE ENTRADA AL CONTADOR, LLAVE DE SALIDA DEL CONTADOR, V�LVULA DE RETENCI�N, GRIFO DE COMPROBACI�N, LATIGUILLO, TAPA CIEGA.'),
('tecnicas_bat_19','1','0','1','18','tecnicas_bat_19','BATER�A NORMALIZADA (GALVANIZADA O PL�STICO)'),
('tecnicas_bat_20','1','1','1','19','tecnicas_bat_20','LLAVES DE SALIDA ROSCA 3/4"'),
('valvularetencionentrada','1','0','0','20','valvularetencionentrada','V�LVULA RETENCI�N ENTRADA BATER�A'),
('idvivienda','1','0','1','21','idvivienda','CUADRO DE CLASIFICACI�N EN LUGAR VISIBLE POR EL QUE SE PUEDE IDENTIFICAR A QU� VIVIENDA CORRESPONDE UN CONTADOR DETERMINADO POR SU POSICI�N EN LA BATER�A'),
('tecnicas_bat_13','1','0','0','22','tecnicas_bat_13//tecnicas_bat_14','TODOS LOS CONTADORES CORRECTAMENTE INSTALADOS Y LEGIBLES'),
('tecnicas_bat_14','1','0','0','22','tecnicas_bat_13//tecnicas_bat_14',''),
('tecnicas_bat_1','1','0','0','23','tecnicas_bat_1','NUMERO CONTADORES EN BATER�A'),
('calibrebat','1','0','0','24','calibrebat','CALIBRES CONTADORES'),
('roscacontadorebat','1','0','0','25','roscacontadorebat','ROSCA ENTRADA'),
('roscacontadorsbat','1','0','0','26','roscacontadorsbat','ROSCA SALIDA'),
('estadobat','1','0','0','27','estadobat','ESTADO DE CONSERVACI�N DE LA INSTALACI�N HIDR�ULICA (BUENO, MALO)');
GO


SELECT * FROM otInspeccionesValidaciones ORDER BY otivServicioCod, otivOrden, otivDescripcion DESC;