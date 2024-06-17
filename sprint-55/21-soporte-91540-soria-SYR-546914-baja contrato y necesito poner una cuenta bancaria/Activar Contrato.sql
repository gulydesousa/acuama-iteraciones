SELECT * 
--UPDATE C SET ctrfecanu=NULL , ctrbaja=0
FROM contratos AS C WHERE ctrcod=949  AND ctrfecanu='2023-12-31T00:00:00.000' and ctrbaja=1 and ctrversion=10


SELECT * 
--UPDATE C SET ctrfecanu='2023-12-31T00:00:00.000',  ctrbaja=1, ctrusrcodanu='palonso'
FROM contratos AS C WHERE ctrcod=949  and ctrversion=10


SELECT * 
--UPDATE C SET ctrfecanu='2023-12-31T00:00:00.100',  ctrbaja=1, ctrfecreg='2023-12-31T00:00:00.000', ctrobs='BAR PATATA (SYR-546914: Asignación de IBAN)'
FROM contratos AS C WHERE ctrcod=949  and ctrversion=11