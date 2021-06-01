USE Northwind

EXEC dbo.GetAllTables
EXEC dbo.GetAllTables
EXEC dbo.CollectStatistics

--5 ����� ���������� �������� �� ������� ���������� �� ���� ������
SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.MaxElapsedTime
DESC
--5 �������� � ���������� ������ ���������� ������ �� ���� ������
SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.MaxPhysicalReads
DESC
--5 �������� � ���������� �������� �� �� ���� ������, �� ��� �������.
SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.MaxWorkerTime
DESC

SELECT TOP 5 * FROM dbo.[ExecStatistics] e
ORDER BY  e.TotalWorkerTime / e.NumberOfExecutions
DESC
