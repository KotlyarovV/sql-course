USE Northwind

EXEC dbo.GetAllTables
EXEC dbo.GetAllTables
EXEC dbo.CollectStatistics

--5 самых длительных процедур по времени выполнения на один запуск
SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.MaxElapsedTime
DESC
--5 процедур с наибольшим числом физических чтений на один запуск
SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.MaxPhysicalReads
DESC
--5 процедур с наибольшим временем ЦП на один запуск, на все запуски.
SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.MaxWorkerTime
DESC

SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.TotalWorkerTime / e.NumberOfExecutions
DESC
