USE Northwind

/*
9.1. �������� ������, ������� ������� � ���� PostalCode �������
dbo.Employees ��� �� �������� ������� �� ����� ��������.
*/

GO

CREATE OR ALTER FUNCTION replaceLetters (@str VARCHAR(1000))
RETURNS VARCHAR(1000)
BEGIN
	WHILE PATINDEX('%[^0-9]%', @str) >0
		SET @str = STUFF(@str, PATINDEX('%[^0-9]%', @str), 1, '2')
	RETURN @str
END;

GO
UPDATE Employees SET PostalCode = dbo.replaceLetters(PostalCode)

/*
9.2. ��������� ���� � �������������� ������, �������������� ����, ���
����� ������ ������ PostalCode ������� �� �� ���������� ������������
(Index Scan), � �� Index Seek. ���������� ��������, ������ ��
�������������� ������ ������ ���?
SELECT EmployeeID
FROM dbo.Employees
WHERE LEFT(PostalCode, 2) = '98'
*/

--�� �����������
SELECT EmployeeID
FROM dbo.Employees
WHERE LEFT(PostalCode, 2) = '98'

--�����
SELECT EmployeeID
FROM dbo.Employees
WHERE PostalCode LIKE '98%'

/*
��������� ������� T-SQL (� ������ ������ ��� left) ������ ������������� �������
��� ����� �������� ������ �� like � ������� ������ ����� �������� ������������ ������
*/

/*
9.3. ����������� � ������ �������, ��������������� ���� �������.
�������������� ������. �������� �������� ������ �� ��������, ��� ���
������� ����������� �������� ������������ ������ ������ � ��������
��� ��������������?
DECLARE @OrderDate DATETIME = N'1996-01-01 00:00:00'
SELECT OrderId = ordr.OrderID,
 EmployeeName = ISNULL(empl.FirstName, '') + ' ' + ISNULL(empl.LastName, ''),
 CustomerId = ordr.CustomerID,
 CompanyName = cust.CompanyName,
 ShippedDate = ordr.ShippedDate,
 ProductName = prod.ProductName
FROM dbo.Orders ordr
INNER JOIN dbo.[Order Details] ord ON ord.OrderID = ordr.OrderID
INNER JOIN dbo.Products prod ON ord.ProductID = prod.ProductID
INNER JOIN dbo.Customers cust ON ordr.CustomerID = cust.CustomerID
INNER JOIN dbo.Employees empl ON ordr.EmployeeID = empl.EmployeeID
WHERE ordr.OrderDate >= @OrderDate
��� �������� �������������� ���������� �������� � ���������������
������� 1000000+ �������. 
*/

GO
	DECLARE @count int = 1000000;
	WHILE @count > 0
		BEGIN
			INSERT INTO Employees (
				LastName, FirstName, Title, TitleOfCourtesy, 
				BirthDate, HireDate, Address, City, Region,
				PostalCode, Country, HomePhone, Extension, 
				Photo, Notes, ReportsTo, PhotoPath)
			VALUES (
				'LastName', 'FirstName', 'Title', 'Dr.', 
				'1950-01-01', '1970-01-01', 'Radialnaya 9', 'London', 'WA',
				'22890', 'UK', '(206) 555-9482', '3448', 
			NULL, NULL, 2, NULL);

			INSERT INTO Products (
				ProductName, SupplierID, CategoryID, 
				QuantityPerUnit, UnitPrice, UnitsInStock,
				UnitsOnOrder, ReorderLevel, Discontinued)
			VALUES (
				'Product name', 1, 1,
				'10 - 1100', 22, 
				56, 1, 5, 0)
				
			INSERT INTO Orders (
				CustomerID, EmployeeID, OrderDate, RequiredDate,
				ShippedDate, ShipVia, Freight, ShipName,
				ShipAddress, ShipCity, ShipRegion, ShipPostalCode,
				ShipCountry, OrderNum, GroupMonthNum)
			VALUES (
				'ALFKI', 1, '2020-01-01', '2020-01-02',
				'2020-01-05', 1, 0.5, 'Name',
				'Address 1', 'City 17', 'region',
				'99999', 'Russia', 2, 1)

			SET @count = @count - 1
		END


/*
����� ���������� � ������� ������� �������� ����� �������
�� �� ������������� join ��, ��� ���������� � ����������� ��������
������ �������� ����� index seek, � �� ����� index scan.

�.�. Order detail �������� ������ �� OrderID � �� ProductID -
� ������ ���������� ���� ������� �������������� ����� � ���

� �������� ����������� ���� ������� ������� ������ �� CustimerID � CompanyName,
����� �������� ���������� CompanyName �� ���� � �������� ������ ��� Employee
�� LastName, FirstName.

��������� ���� ��������� � ���� ��� ��������
*/
CREATE NONCLUSTERED INDEX Customer_Index_CompanyName   
    ON dbo.Customers (CustomerID, CompanyName);

CREATE NONCLUSTERED INDEX Employee_Index_Last_First_Name 
    ON dbo.Employees (LastName, FirstName);

DECLARE @OrderDate DATETIME = N'1996-01-01 00:00:00'
SELECT OrderId = ordr.OrderID,
 EmployeeName = ISNULL(empl.FirstName, '') + ' ' + ISNULL(empl.LastName, ''),
 CustomerId = ordr.CustomerID,
 CompanyName = cust.CompanyName,
 ShippedDate = ordr.ShippedDate,
 ProductName = prod.ProductName
FROM dbo.Orders ordr
INNER JOIN dbo.[Order Details] ord ON ord.OrderID = ordr.OrderID
INNER JOIN dbo.Products prod ON ord.ProductID = prod.ProductID
INNER JOIN dbo.Customers cust ON ordr.CustomerID = cust.CustomerID
INNER JOIN dbo.Employees empl ON ordr.EmployeeID = empl.EmployeeID
WHERE ordr.OrderDate >= @OrderDate
