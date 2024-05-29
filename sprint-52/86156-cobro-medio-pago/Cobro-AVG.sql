/*
Necesito modificar un cobro, que ha sido abonado con tarjeta y no por transferencia bancaria. 
La cliente se ha ido ya con la tarjeta, por lo que necesito, por favor, solo modificar, no anular. 
El numero de cobro es 100015485 y el P. Pago es el 10.

*/


--ALTER TABLE cobros NOCHECK CONSTRAINT ALL
--ALTER TABLE coblin NOCHECK CONSTRAINT ALL
--ALTER TABLE cobLinDes NOCHECK CONSTRAINT ALL

SELECT * 
--UPDATE C SET cobPpag = 10
FROM cobros AS C WHERE  cobCtr=4451 AND cobNum=100015485 AND cobPpag=6 AND cobScd=1

SELECT * 
--UPDATE C SET cblPpag=10
FROM coblin AS C WHERE cblNum=100015485 AND cblPpag=6 AND cblScd=1

SELECT * , SUM(cldImporte) OVER()
--UPDATE C SET cldCblPpag=10
FROM cobLinDes AS C WHERE cldcblNum=100015485 AND cldcblPpag=6 AND cldcblScd=1

--ALTER TABLE cobros CHECK CONSTRAINT ALL
--ALTER TABLE coblin CHECK CONSTRAINT ALL
--ALTER TABLE cobLinDes CHECK CONSTRAINT ALL


--SELECT * FROM ppagos
--SELECT * FROM medpc