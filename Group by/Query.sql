USE Northwind

/*
3.1.1. ����� ����� ����� ���� ������� �� ������� Order Details � ������
���������� ����������� ������� � ������ �� ���.
��������� ��������� �� ����� � ��������� � ����� 1 ��� ���� ������ money.
������ (������� Discount) ���������� ������� �� ��������� ��� ������� ������.
��� ����������� �������������� ���� �� ��������� ������� ���� �������
������ �� ��������� � ������� UnitPrice ����.
����������� ������� ������ ���� ���� ������ � ����� �������� � ���������
������� 'Totals'
*/
GO

SELECT 
CONVERT(VARCHAR, SUM(CAST(UnitPrice * Quantity * (1 - Discount) AS MONEY)), 1) AS Totals
FROM dbo.[Order Details];

/*
3.1.2. �� ������� Orders ����� ���������� �������, ������� ��� �� ����
���������� (�.�. � ������� ShippedDate ��� �������� ���� ��������).
������������ ��� ���� ������� ������ �������� COUNT.
�� ������������ ����������� WHERE � GROUP.
*/
GO

SELECT 
COUNT(*) - COUNT(ShippedDate) AS [Number of non shipped orders]
FROM dbo.Orders ;

/*
3.1.3. �� ������� Orders ����� ���������� ��������� ����������� (CustomerID),
��������� ������.
������������ ������� COUNT � �� ������������ ����������� WHERE � GROUP.
*/
GO

SELECT 
COUNT(DISTINCT CustomerID) AS [Customer number]
FROM dbo.Orders;

/*
3.2.1. �� ������� Orders ����� ���������� ������� � ������������ �� �����.
� ����������� ������� ���� ����������� ��� ������� c ���������� Year � Total.
�������� ����������� ������, ������� ��������� ���������� ���� �������.\
*/
GO

SELECT 
YEAR(OrderDate) AS [Year], 
COUNT(*) AS [Total] 
FROM dbo.Orders 
GROUP BY YEAR(OrderDate);

SELECT 
COUNT(*) AS [Orders count] 
FROM dbo.Orders;

/*
3.2.2. �� ������� Orders ����� ���������� �������, ����������� ������
���������.
����� ��� ���������� �������� � ��� ����� ������ � ������� Orders, ��� � �������
EmployeeID ������ �������� ��� ������� ��������.
� ����������� ������� ���� ����������� ������� � ������ �������� (������
������������� ��� ���������� ������������� LastName & FirstName. ��� ������
LastName & FirstName ������ ���� �������� ��������� �������� � �������
��������� �������. ����� �������� ������ ������ ������������ �����������
�� EmployeeID.) � ��������� ������� �Seller� � ������� c ����������� �������
����������� � ��������� 'Amount'.
���������� ������� ������ ���� ����������� �� �������� ���������� �������.
*/
GO

SELECT 
	COUNT(*) AS Amount, 
	(SELECT 
		LastName + N' ' + FirstName 
		FROM dbo.Employees e 
		WHERE e.EmployeeID = o.EmployeeID) AS Seller
FROM dbo.Orders o
GROUP BY EmployeeID
ORDER BY Amount DESC;

/*
3.2.3 �� ������� Orders ����� ���������� �������
�������:
� ������ ������� ������ ��������� � ��� ������� ����������;
� ������ ������� � 1998 ����.
� ����������� ������� ���� �����������:
� ������� � ������ �������� (�������� ������� �Seller�);
� ������� � ������ ���������� (�������� ������� �Customer�);
� ������� c ����������� ������� ����������� � ��������� 'Amount'.
� ������� ���������� ������������ ����������� �������� ����� T-SQL ���
������ � ���������� GROUP (���� �� �������� ������� �������� ������ �ALL�
� ����������� �������).
����������� ������ ���� ������� �� ID �������� � ����������.
���������� ������� ������ ���� ����������� ��:
� ��������;
� ����������;
� �������� ���������� ������.

*/
GO

SELECT (
	CASE 
		WHEN GROUPING(o.EmployeeID) = 1 THEN N'ALL'
		ELSE (SELECT e.LastName + N' ' + e.FirstName AS Name 
			FROM dbo.Employees e 
			WHERE e.EmployeeID = o.EmployeeID)
	END
) AS Seller, 
(
	CASE 
		WHEN GROUPING(o.CustomerID) = 1 THEN 'ALL'
		ELSE (SELECT ContactName 
			FROM dbo.Customers c 
			WHERE c.CustomerID = o.CustomerID)
	END
) AS Customer, 
COUNT(*) AS Amount 
FROM dbo.Orders o
WHERE YEAR(o.OrderDate) = 1998
GROUP BY GROUPING SETS(CUBE(o.EmployeeID, o.CustomerID))
ORDER BY Seller ASC, Customer ASC, Amount DESC;

/*
3.2.4. ����� ����������� � ���������, ������� ����� � ����� ������.
���� � ������ ����� ������ �������� ��� ������ ����������, �� ���������� �
����� ���������� � ��������� �� ������ �������� � �������������� �����.
� ����������� ������� ���������� ������� ��������� ��������� ��� �����������
�������:
� �Person�;
� �Type� (����� ���� �������� ������ �Customer� ��� �Seller� � ��������� ��
���� ������);
� �City�.
������������� ���������� ������� �� ������� �City� � �� �Person�.
*/
GO

SELECT * FROM (
		SELECT ContactName AS Person, City, 'Customer' AS [Type] 
		FROM dbo.Customers c
		UNION
		SELECT e.LastName + N' ' + e.FirstName AS Person, City, 'Seller' AS [Type] 
		FROM dbo.Employees e
	) AS Persons
WHERE City IN 
	(SELECT c.City 
	FROM dbo.Employees e
	JOIN dbo.Customers c ON c.City = e.City
	GROUP BY c.City)
ORDER BY City, Person;

/*
3.2.5. ����� ���� �����������, ������� ����� � ����� ������.
� ������� ������������ ���������� ������� Customers c ����� -
��������������. ��������� ������� CustomerID � City.
������ �� ������ ����������� ����������� ������.
��� �������� �������� ������, ������� ����������� ������, �������
����������� ����� ������ ���� � ������� Customers. ��� �������� ���������
������������ �������.
*/
GO

SELECT c.CustomerID AS CustomerID, c.City AS City 
FROM dbo.Customers c
JOIN dbo.Customers c1 ON c.City = c1.City
GROUP BY c.CustomerID, c.City
HAVING COUNT(c.CustomerID) > 1
ORDER BY City;

--����� ��� �������� ������� ������������ ������ � ���-��� ������� ���
SELECT COUNT(*) AS [Order count], City 
FROM dbo.Customers 
GROUP BY City 
HAVING COUNT(*) > 1 
ORDER BY City;

/*
3.2.6. �� ������� Employees ����� ��� ������� �������� ��� ������������, �.�.
���� �� ������ �������.
��������� ������� � ������� 'User Name' (LastName) � 'Boss'. � �������� ������
���� ��������� ����� �� ������� LastName.
��������� �� ��� �������� � ���� �������?
*/
GO

SELECT e.LastName AS [User Name], e1.LastName AS [Boss] 
FROM dbo.Employees e
JOIN dbo.Employees e1 ON e.ReportsTo = e1.EmployeeID;

--� ������� ��������� �� ��� ��������, �.�. � ���� �� �� ��������� ��� ������������