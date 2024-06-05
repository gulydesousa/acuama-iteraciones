--Datos

TRUNCATE TABLE otInspeccionesValidaciones;
GO

SET NOCOUNT ON;

--CONTADOR INDIVIDUAL
INSERT INTO otInspeccionesValidaciones
VALUES
('llavepaso', '2', '1', '1', '1', 'llavepaso', 'LLAVE DE PASO Y ARQUETA EN ACERA', 0, ''), 
('tuberiaentrada', '2', '1', '1', '2', 'tuberiaentrada', 'TUBER�A DE ENTRADA AL EDIFICIO AL DESCUBIERTO EN UN TRAMO DE 35 CM EN EL QUE PRESENTA TOTAL HORIZONTALIDAD', 0, NULL), 
('arquetaconpuerta', '2', '0', '1', '3', 'arquetaconpuerta//arquetafachada//arquetanivelsuelo', 'TRAMO DE TUBER�A EN EL INTERIOR DE UN ARMARIO CON PUERTA DE 300X250X160 MM, INSTALADA EN FACHADA DEL EDIFICIO A UNA ALTURA DE ENTRE 0,90 M Y 1,5 M DESDE EL NIVEL DEL SUELO', 0, NULL), 
('arquetafachada', '2', '0', '1', '3', 'arquetaconpuerta//arquetafachada//arquetanivelsuelo', '', 0, NULL), 
('arquetanivelsuelo', '2', '0', '1', '3', 'arquetaconpuerta//arquetafachada//arquetanivelsuelo', '', 0, NULL), 
('juegollaves', '2', '1', '1', '4', 'juegollaves', 'JUEGO DE LLAVE DE ENTRADA Y SALIDA', 0, NULL), 
('valvularetencion', '2', '1', '0', '5', 'valvularetencion', 'V�LVULA DE RETENCI�N', 0, NULL), 
('roscacontadore', '2', '0', '0', '6', 'roscacontadore', 'DI�METRO ROSCA ENTRADA', 0, NULL), 
('roscacontadors', '2', '0', '0', '7', 'roscacontadors', 'DI�METRO ROSCA SALIDA', 0, NULL), 
('estadocontador', '2', '1', '0', '8', 'estadocontador', 'ESTADO DE CONSERVACI�N DE LA INSTALACI�N HIDR�ULICA (BUENO, MALO)', 0, NULL);
GO

--BATERIAS
INSERT INTO otInspeccionesValidaciones
VALUES
('sepradogas','1','1','1','1','sepradogas//plantabaja','UBICACI�N EN PLANTA BAJA DEL EDIFICIO SEPARA DE DEPENDENCIAS DESTINADAS A GAS Y ELECTRICIDAD', 0, NULL),
('plantabaja','1','1','1','1','sepradogas//plantabaja','', 0, NULL),
('usocomun','1','0','1','2','usocomun//llavepasocerca','UBICACI�N EN ZONA DE F�CIL ACCESO Y USO COM�N DEL INMUEBLE, LO M�S CERCA POSIBLE DE LA LLAVE DE PASO DEL EDIFICIO', 0, NULL),
('llavepasocerca','1','0','1','2','usocomun//llavepasocerca','', 0, NULL),
('armarioid','1','0','1','3','armarioid//armario12','PUERTA DEL  ARMARIO IDENTIFICADA CON UNA O M�S HOJAS DEJANDO LIBRE AL ABRIRSE TODO EL ANCHO DEL MISMO', 0, NULL),
('armario12','1','0','1','3','armarioid//armario12','', 0, NULL),
('instestanca','1','1','1','4','instestanca','CUARTO DOTADO DE ILUMINACI�N EL�CTRICA ESTANCA ', 0, NULL),
('desague','1','1','1','5','desague','PILETA DE GOTEO CON DESAG�E A LA ALCANTARILLA CON COTA ADECUADA', 0, NULL),
('aljibe','1','0','1','6','aljibe','EL ACCESO AL ALJIBE Y/O GRUPO DE PRESI�N SEPARADO DE LA PUERTA DE ACCESO AL CUARTO DE CONTADORES Y LA ZONA DE LECTURA', 0, NULL),
('armariounico','1','0','1','7','armariounico','CUARTO O ARMARIO DESTINADO EN EXCLUSIVA A INSTALACIONES DE CONTADORES DE AGUA', 0, NULL),
('llavescontadores','1','0','1','8','llavescontadores','CERRADURA DE LOS MODELOS ACEPTADOS POR EL SERVICIO', 0, NULL),
('tecnicas_bat_9','1','1','1','9','tecnicas_bat_9','BATER�A EN CIRCUITO CERRADO CON TRES TUBOS HORIZONTALES COMO M�XIMO', 0, NULL),
('tecnicas_bat_10','1','0','0','10','tecnicas_bat_10','FILA SUPERIOR DE CONTADORES M�XIMO A 1,60 M DE ALTURA DESDE EL SUELO O PUNTO DESDE EL QUE PISA EL LECTOR O INSPECTOR Y M�NIMO A 0,50 M METROS DEL TECHO', 0, NULL),
('tecnicas_bat_11','1','0','1','11','tecnicas_bat_11','FILA INFERIOR SITUADA COMO M�NIMO A 0,50 M DE ALTURA DESDE EL SUELO Y SEPARACI�N ENTRE FILAS DE 0,25 M. DISTANCIA DEL FONDO DE LA PARED 0,16 Y FILAS DE 3 M DE ANCHO', 0, NULL),
('tecnicas_bat_12','1','1','0','12','tecnicas_bat_12','LOS RAMALES PRESENTAN HORIZONTALIDAD EN UN TRAMO M�NIMO DE 35 CM', 0, NULL),
('juegollavesbat','1','1','1','13','juegollavesbat','LLAVES DE ENTRADA Y SALIDA EN CONTADORES', 0, NULL),
('tecnicas_bat_15','1','0','1','14','tecnicas_bat_15','LA BRIDA DE CONEXI�N A LA LLAVE DE ENTRADA A CONTADOR OVALADA, ORIENTADA DE FORMA QUE EL EJE MAYOR SEA PERPENDICULAR A LA PARED', 0, NULL),
('tecnicas_bat_16','1','1','1','15','tecnicas_bat_16','V�LVULA DE RETENCI�N INCORPORADA EN LOS CONTADORES DE SALIDA.', 0, NULL),
('tecnicas_bat_17','1','1','1','16','tecnicas_bat_17','LLAVES PROVISTAS DE MANGUITO CON JUNTA INCORPORADA, SIN CONTRARROSCAS', 0, NULL),
('tecnicas_bat_18','1','1','0','17','tecnicas_bat_18','BATER�A NO SIMULADA: LLAVE DE CORTE, BATER�A EN CIRCUITO CERRADO, LLAVE DE ENTRADA AL CONTADOR, LLAVE DE SALIDA DEL CONTADOR, V�LVULA DE RETENCI�N, GRIFO DE COMPROBACI�N, LATIGUILLO, TAPA CIEGA.', 0, NULL),
('tecnicas_bat_19','1','0','1','18','tecnicas_bat_19','BATER�A NORMALIZADA (GALVANIZADA O PL�STICO)', 0, NULL),
('tecnicas_bat_20','1','1','1','19','tecnicas_bat_20','LLAVES DE SALIDA ROSCA 3/4"', 0, NULL),
('valvularetencionentrada','1','0','0','20','valvularetencionentrada','V�LVULA RETENCI�N ENTRADA BATER�A', 0, NULL),
('idvivienda','1','0','1','21','idvivienda','CUADRO DE CLASIFICACI�N EN LUGAR VISIBLE POR EL QUE SE PUEDE IDENTIFICAR A QU� VIVIENDA CORRESPONDE UN CONTADOR DETERMINADO POR SU POSICI�N EN LA BATER�A', 0, NULL),
('tecnicas_bat_13','1','0','0','22','tecnicas_bat_13//tecnicas_bat_14','TODOS LOS CONTADORES CORRECTAMENTE INSTALADOS Y LEGIBLES', 0, NULL),
('tecnicas_bat_14','1','0','0','22','tecnicas_bat_13//tecnicas_bat_14','', 0, NULL),
('tecnicas_bat_1','1','0','0','23','tecnicas_bat_1','NUMERO CONTADORES EN BATER�A', 0, NULL),
('calibrebat','1','0','0','24','calibrebat','CALIBRES CONTADORES', 0, NULL),
('roscacontadorebat','1','0','0','25','roscacontadorebat','ROSCA ENTRADA', 0, NULL),
('roscacontadorsbat','1','0','0','26','roscacontadorsbat','ROSCA SALIDA', 0, NULL),
('estadobat','1','0','0','27','estadobat','ESTADO DE CONSERVACI�N DE LA INSTALACI�N HIDR�ULICA (BUENO, MALO)', 0, NULL);
GO



-- Imprimir las filas afectadas
DECLARE @i INT;
SELECT @i = COUNT(*) FROM otInspeccionesValidaciones;
PRINT '        otInspeccionesValidaciones: ' + CAST(@i AS NVARCHAR(10))+ ' filas';


SET NOCOUNT OFF;