USE Northwind

IF EXISTS(
SELECT TOP(1) 1
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = N'Accounts' AND TABLE_SCHEMA = 'dbo'
)
DROP TABLE dbo.Accounts
CREATE TABLE dbo.Accounts (
	CounterpartyID	INT,
	[Name]			VARCHAR(255),
	IsActive		BIT
)

INSERT INTO 
dbo.Accounts (CounterpartyID, [Name], IsActive) 
VALUES
(1, N'������', 1),
(2, N'������', 0),
(3, N'�������', 1)


IF EXISTS(
SELECT TOP(1) 1
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = N'Transits' AND TABLE_SCHEMA = 'dbo'
)
DROP TABLE dbo.Transits
CREATE TABLE dbo.Transits (
	TransID		INT,
	TransDate	DATE,
	RcvID		INT,
	SndID		INT,
	AssetID		INT,
	Quantity	NUMERIC(19, 8)
)

INSERT INTO 
dbo.Transits(TransID, TransDate, RcvID, SndID, AssetID, Quantity) 
VALUES
(1, '2012-01-01', 1, 2, 1, 100),
(2, '2012-01-02', 1, 3, 2, 150),
(3, '2012-01-03', 3, 1, 1, 300),
(4, '2012-01-04', 2, 1, 3, 50)
GO

/*
1) �������� �������� ����� �� ������� ���� �������� ��� ������� ��
���� ������ �������. ��������� ����: CounterpartyID, Name,
Cnt(���������� ���������� ������� �� ������� ���� ��������)
*/

;WITH AccoundIDWithAssetID
AS (
	SELECT 
		t.RcvID AS AcID, t.AssetID 
	FROM
		dbo.Transits t
	UNION
	SELECT 
		t.SndID AS AcID, t.AssetID 
	FROM
		dbo.Transits t
)
SELECT 
	a.CounterpartyID, a.Name, COUNT(aa.AssetID) AS [Assets number] 
FROM 
	AccoundIDWithAssetID aa
JOIN 
	Accounts a ON a.CounterpartyID = aa.AcID
WHERE a.IsActive = 1
GROUP BY a.CounterpartyID, a.Name
HAVING COUNT(aa.AssetID) >= 2;

GO
/*
2) ��������� ��������� ����� ������, �������������� �� ��������
������, � ���������� ����������� ��������. ��������� ����:
CounterpartyID, Name, AssetID, Quantity
*/
;WITH TransferInf
AS (
	SELECT 
		t.RcvID AS AcID, t.AssetID, t.Quantity 
	FROM
		dbo.Transits t
	UNION ALL
	SELECT 
		t.SndID AS AcID, t.AssetID, - t.Quantity
	FROM
		dbo.Transits t
)
SELECT 
	a.CounterpartyID, a.Name, t.AssetID, SUM(t.Quantity)
FROM 
	TransferInf t
JOIN 
	Accounts a ON a.CounterpartyID = t.AcID
WHERE a.IsActive = 1
GROUP BY a.CounterpartyID, a.Name, t.AssetID;

GO
/*
3) ��������� ������� ������� ������ �� ���� ������ �� ����
��������� ������ ��� AssetID �� ���� ��������� ����������.
��������� ����: CounterpartyID, Name, Oborot*/;WITH TransferInf
AS (
	SELECT t.AcID, SUM(t.Quantity) AS Quantity 
	FROM (
		SELECT t.RcvID AS AcID, t.Quantity, t.TransDate FROM
		dbo.Transits t
		UNION ALL
		SELECT t.SndID AS AcID, t.Quantity, t.TransDate 
		FROM
		dbo.Transits t) t
	GROUP BY t.AcID, t.TransDate
) SELECT 	a.CounterpartyID, a.Name, AVG(inf.Quantity) as Oborot FROM TransferInf infJOIN 
	Accounts a ON a.CounterpartyID = inf.AcIDGROUP BY a.CounterpartyID, a.Name;GO/*4) ��������� ������� �������� ������ �� ���� ������ �� ����
��������� ������ ��� AssetID �� ���� ��������� ����������.
��������� ����: CounterpartyID, Name, Oborot
*/

;WITH TransferInf
AS (
	SELECT t.AcID, SUM(t.Quantity) AS Quantity 
	FROM (
		SELECT t.RcvID AS AcID, t.Quantity, t.TransDate FROM
		dbo.Transits t
		UNION ALL
		SELECT t.SndID AS AcID, t.Quantity, t.TransDate 
		FROM
		dbo.Transits t) t
	GROUP BY t.AcID, YEAR(t.TransDate), MONTH(t.TransDate)
) SELECT 	a.CounterpartyID, a.Name, AVG(inf.Quantity) as Oborot FROM TransferInf infJOIN 
	Accounts a ON a.CounterpartyID = inf.AcIDGROUP BY a.CounterpartyID, a.Name;GO/*6.2. �� ������� dbo.Employees ��� ������� ������������ ����� �����������
�� ���� ������� �������� ���������� (������� � ����� ������
�����������). ������� ������������, ������������, �����������������
������������ � ������� ����������.
��� ���������� �������� � ������� ������������ ���� EmploeeID �
ReportsTo.
���������� ������������ ������������ CTE.
*/

;WITH RecCTE
AS (
	SELECT 
		e.EmployeeID, e.LastName as ������������, e1.EmployeeID as EmId, 
		e1.LastName as �����������, 0 AS [������� ����������], e1.ReportsTo
	FROM dbo.Employees e
	JOIN dbo.Employees e1 on e1.ReportsTo = e.EmployeeID
	UNION ALL
	SELECT 
		s.EmployeeID, s.������������, e2.EmployeeID as EmId,
		e2.LastName as �����������, [������� ����������] + 1, e2.ReportsTo
	FROM RecCTE s
	JOIN dbo.Employees e2 on e2.ReportsTo = s.EmId
	)
SELECT r.������������, r.�����������, r.[������� ����������], e.LastName as [���������������� ������������]
FROM RecCTE r
JOIN dbo.Employees e on e.EmployeeID = r.ReportsTo
ORDER BY r.������������
