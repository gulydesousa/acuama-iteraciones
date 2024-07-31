SELECT * FROM Task_Types


SELECT * 
--UPDATE T SET tskStatus=3
FROM Task_Schedule AS T
WHERE tskType=410 and tskFinishedDate>='20240709'
AND tskStartedDate>'20240703'
ORDER BY tskScheduledDate DESC

SELECT * FROM Task_Schedule AS T
WHERE tskType=410  
ORDER BY tskScheduledDate DESC



SELECT * 
--UPDATE T SET tskStatus=4, tskFinishedDate=GETDATE()
FROM Task_Schedule AS T
WHERE tskType=410 --and tskFinishedDate>='20240709'
--AND tskStartedDate>'20240703'
ORDER BY tskScheduledDate DESC
