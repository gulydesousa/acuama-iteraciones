SELECT * FROM cobros WHERE cobNum='10891028'and cobCtr=110504373

SELECT * FROM cobLinEfectosPendientes WHERE clefePdteCtrCod=110504373 AND cleCblNum=10891028
SELECT * FROM cobLinEfectosPendientes WHERE clefePdteCtrCod=110504373 AND cleCblNum=10890857

--Respecto al cobro 10890857, est� bien cobrado, 
--lo que est� mal es su interpretaci�n (l�gica para los mortales, pero no para Acuama) de la consulta del mismo, 
--ya que lo que sale en esa consulta no es lo que se cobra.
--Los 4 efectos que aparecen el cobro 10890857 de m�s, est�n cobrados en el n� de cobro 10891028.

SELECT * 
--UPDATE E SET cleCblNum=10891028
FROM cobLinEfectosPendientes AS E
WHERE clefePdteCtrCod=110504373 
AND cleCblNum=10890857
AND clefePdteCod IN(9487136, 9487137, 9487138, 9487139)