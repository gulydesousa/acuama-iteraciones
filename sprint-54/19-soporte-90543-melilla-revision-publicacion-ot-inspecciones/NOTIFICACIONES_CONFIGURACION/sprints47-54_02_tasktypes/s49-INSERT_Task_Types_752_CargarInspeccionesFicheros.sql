IF NOT EXISTS(SELECT 1 FROM Task_Types WHERE tskTDesc='CargarInspeccionesFicheros')
INSERT INTO Task_Types VALUES(752, 'CargarInspeccionesFicheros', 0);


SELECT * 
--DELETE
FROM Task_Types WHERE tskTDesc='CargarInspeccionesFicheros'
