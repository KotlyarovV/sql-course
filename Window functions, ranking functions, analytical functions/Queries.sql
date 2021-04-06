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
Value. � ������� ���� ������ ���� �������� �������� 1, 5, 7, 9
����� �������� Value � ���������� �������. ��������� ����:
PeriodID, Value. � ������� ���� ������ ���� ������� �������� 3, 6,
10.
������� ������ �� ��������.
����������� �� ����� ������ ������ ����