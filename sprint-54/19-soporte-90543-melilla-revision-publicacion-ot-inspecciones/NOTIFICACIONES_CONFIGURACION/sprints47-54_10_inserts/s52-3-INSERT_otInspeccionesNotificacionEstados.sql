
INSERT INTO otInspeccionesNotificacionEstados VALUES
(1, 'Entregado', 'Notificado correctamente', 1, 0),
(2, 'Dirección incorrecta', '', 0, 1),
(3, 'Ausente', 'A lo sumo se pueden hacer dos reintentos, el intento siguiente puede ser Entregado en lista BOE', 0, 0),
(4, 'Desconocido', '', 0, 1),
(5, 'Fallecido', '', 0, 1),
(6, 'Rehusado', '', 0, 1),
(7, 'No se hace cargo', '', 0, 1),
(8, 'Entregado en lista', 'Publicación en la lista del BOE: Por defecto u ordinaria la notificación a través de la empresa', 1, 0),
(9, 'No entregado en lista', 'Publicación en la lista del BOE: Si no es existosa y se refiera a la de publicación en el BOE', 0, 1)


SELECT * FROM otInspeccionesNotificacionEstados;
