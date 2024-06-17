--DELETE FROM parametros WHERE pgsclave='cApremiosTrabBL'
--SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'

DECLARE @valor AS VARCHAR(5)= '54'
SELECT @valor= CASE pgsvalor 
				WHEN 'Alamillo' THEN ''			
				WHEN 'Almaden' THEN ''			
				WHEN 'AVG' THEN ''				
				WHEN 'Biar' THEN ''				
				WHEN 'Guadalajara' THEN '54'	
				WHEN 'Melilla' THEN ''			
				WHEN 'Ribadesella' THEN ''		
				WHEN 'Soria' THEN ''			
				WHEN 'SVB' THEN ''				
				WHEN 'Valdaliga' THEN ''		
				ELSE '' END
FROM parametros AS P WHERE pgsclave='EXPLOTACION';


IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'))
	INSERT INTO parametros 
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	VALUES('cApremiosTrabBL','Version por Sprint',2, @valor,0,1, 0)
ELSE 
	UPDATE P SET pgsvalor=@valor
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	FROM parametros AS P WHERE pgsclave='cApremiosTrabBL'