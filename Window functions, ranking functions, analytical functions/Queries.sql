USE Northwind

/*
�������� ���������� ������� �� �������� ����������:
��� ������ ��������� �������� (���� CategoryName �� �������
Categories) ������� ������� ��������� ������� ��� ����������� ��
�������� AK, BC, CA, Co. Cork (���� Region �� ������� Customers)

��������� ������� � ���� ������� :
CategoryName AK BC CA Co. Cork
<��������� 1> <����������> <����������> <����������> <����������>
....
���������� ������������ �������� PIVOT
*/

;WITH PivotData
AS 
(
SELECT 
	c.CategoryName, 
	od.Quantity * od.UnitPrice * (1 - od.Discount) AS Price, 
	o.ShipRegion 
FROM [Order Details] od
	JOIN dbo.Products p ON p.ProductID = od.ProductID
	JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
	JOIN dbo.Orders o ON o.OrderID = od.OrderID)
SELECT 
	CategoryName, AK, BC, CA, [Co. Cork] 
FROM PivotData 
PIVOT (AVG(Price) FOR ShipRegion IN ([AK],[BC], [CA], [Co. Cork])) AS P;

/*
������� ��������� ������� #Periods � ����� ������: PeriodID, Value.
������ ���������� �������
PeriodID Value
1 10
3 10
5 20
6 20
7 30
9 40
10 40
*/

CREATE TABLE #Periods (
	PeriodID INT,
	[Value] INT
)

INSERT INTO #Periods 
VALUES (1, 10), (3, 10), (5, 20), (6, 20), (7, 30), (9, 40), (10, 40)

/*
7.2.1. ��������� �������� ������� � ������� �������� Value ����������
�� �������� Value � ���������� �������. ��������� ����: PeriodID,
Value. � ������� ���� ������ ���� �������� �������� 1, 5, 7, 9*/;WITH CTE_ValuesAS (SELECT	*, LAG(Value) OVER(ORDER BY PeriodID) AS PreviousFROM #Periods)SELECT PeriodID FROM CTE_Values WHERE 	Value <> Previous OR Previous IS NULL/*7.2.2. ��������� ������� �� ������� ������� � ������� �������� Value
����� �������� Value � ���������� �������. ��������� ����:
PeriodID, Value. � ������� ���� ������ ���� ������� �������� 3, 6,
10.*/;WITH CTE_ValuesAS (SELECT	*, LAG(Value) OVER(ORDER BY PeriodID) AS PreviousFROM #Periods)DELETE FROM #Periods WHERE PeriodID IN (	SELECT 		PeriodID 	FROM CTE_Values v	WHERE v.[Value] = v.Previous)/*7.3.1. ������������ ������ �� ������� Orders � ������� ����������
������� ������ �� ��������.*/SELECT 	*, ROW_NUMBER() OVER(ORDER BY ShippedDate - OrderDate DESC) AS OrderTimeNumber FROM Orders/*7.3.2. �������� �� ��������� ���������, � ������� ����������
����������� �� ����� ������ ������ ����*/;WITH CTE_CategoryAS (SELECT 	c.CategoryID,	COUNT(c.Country) 	OVER (		PARTITION BY c.CategoryID, c.Country 		ORDER BY CategoryID, c.Country) AS CountryNumberFROM (SELECT 	DISTINCT p.CategoryID, p.SupplierID, s.CountryFROM dbo.Products p	JOIN dbo.Suppliers s ON s.SupplierID = p.SupplierID)AS c)SELECT * FROM dbo.Categories c WHERE c.CategoryID IN (	SELECT ca.CategoryID 	FROM CTE_Category ca 	WHERE ca.CountryNumber > 3)--7.3.3.exec FillOrderNum;--7.3.4.exec FillGroupMonthNum;--7.3.5exec ShowPages 5;