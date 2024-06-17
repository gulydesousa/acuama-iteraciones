--**********************************
--Contratos que entraban en las remesa #1313
SELECT DISTINCT cobCtr 
--INTO SYR547225_CTRCOD
FROM SYR547225_1

--**********************************
--Contratos que entraban en las remesa #1316
SELECT DISTINCT cobCtr 
FROM SYR547225_2


--**********************************
--Comprobamos que efectivamente estaban en la primera remesa
SELECT * FROM  SYR547225_CTRCOD WHERE cobctr IN (67880, 110152940)






SELECT * FROM SYR547225_1 WHERE cobctr = 110152940
SELECT * FROM SYR547225_1 WHERE cobctr = 109400547
SELECT * FROM SYR547225_1 WHERE cobctr = 110192674
