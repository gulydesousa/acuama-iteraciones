--DELETE FROM parametros WHERE pgsclave='cApremiosTrabBL'
--SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'

DECLARE @valor AS VARCHAR(5)= '540'

IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'))
	INSERT INTO parametros 
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	VALUES('cApremiosTrabBL','Version por Sprint',2, @valor,0,1, 0)
ELSE 
	UPDATE P SET pgsvalor=@valor
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	FROM parametros AS P WHERE pgsclave='cApremiosTrabBL'