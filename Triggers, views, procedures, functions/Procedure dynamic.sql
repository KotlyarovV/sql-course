USE Northwind

/*
1. �������� ���������, ������� ���������� ����� ������� ����� ���
������� �� ��������� �� ������������ ���.
� ����������� �� ����� ���� ��������� ������� ������ ��������, ������ ����
������ ���� � ����� �������.
� ����������� ������� ������ ���� �������� ��������� �������: ������� �
������ � �������� �������� (FirstName � LastName � ������: Nancy Davolio),
����� ������ � ��� ���������.
� ������� ���� ��������� Discount ��� ������� �������.
��������� ���������� ���, �� ������� ���� ������� �����, � ����������
������������ �������.
���������� ������� ������ ���� ����������� �� �������� ����� ������.
��������� ������ ���� ����������� 2-�� ��������� � ��������������
��������� SELECT � � �������������� �������.
�������� �������� �������������� GreatestOrders � GreatestOrdersCur.
���������� ������������������ ������������� ���� ��������. 
*/

GO

CREATE OR ALTER PROCEDURE GreatestOrders
	@year INT,
	@recordNumber INT
AS
BEGIN

SELECT TOP(@recordNumber) 
e.FirstName + ' ' + e.LastName AS [Employee name], 
MAX(o.OrderID) AS [Order number], --�� ������, ���� ������� � ������������ ������ ���������
o.OrderPrice 
FROM
	(SELECT o.EmployeeID, MAX(o.OrderPrice) AS MaxOrderPrice FROM 
		(SELECT 
			o.OrderID, 
			o.EmployeeID,
			SUM((1 - od.Discount) * od.UnitPrice * od.Quantity) AS OrderPrice
		FROM dbo.Orders o
		JOIN [Order Details] od ON od.OrderID = o.OrderID
		WHERE YEAR(o.OrderDate) = @year
		GROUP BY o.OrderID, o.EmployeeID
		) o
	GROUP BY o.EmployeeID) employeesWithMaxSums
JOIN 
(SELECT
	o.OrderID, 
	o.EmployeeID,
	SUM((1 - od.Discount) * od.UnitPrice * od.Quantity) AS OrderPrice
	FROM dbo.Orders o
	JOIN dbo.[Order Details] od ON od.OrderID = o.OrderID
	WHERE YEAR(o.OrderDate) = @year
	GROUP BY o.OrderID, o.EmployeeID
	) o
ON
	employeesWithMaxSums.EmployeeID = o.EmployeeID 
	AND
	employeesWithMaxSums.MaxOrderPrice = o.OrderPrice
JOIN dbo.Employees e ON e.EmployeeID = employeesWithMaxSums.EmployeeID
GROUP BY o.OrderPrice, e.FirstName, e.LastName
ORDER BY o.OrderPrice DESC;

END;

GO

CREATE OR ALTER PROCEDURE GreatestOrdersCur
	@year INT,
	@recordNumber INT
AS	
BEGIN

	CREATE TABLE #employeesWithBiggestOrders
	(
		[Employee name] VARCHAR(200),
		[Order number] INT,
		OrderPrice REAL
	);

	DECLARE @name VARCHAR(200), @number INT, @orderPrice REAL, @orderId INT;

	DECLARE employers_cursor CURSOR FOR
		(SELECT 
		e.EmployeeID, 
		e.FirstName + ' ' + e.LastName AS [Employee name] 
		FROM dbo.Employees e
		WHERE e.EmployeeID in (
			SELECT EmployeeID 
			FROM dbo.Orders o
			JOIN dbo.[Order Details] od on od.OrderID = o.OrderID
			WHERE YEAR(o.OrderDate) = @year));

	OPEN employers_cursor;

	FETCH NEXT FROM employers_cursor INTO @number, @name;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @orderId = o.OrderID, @orderPrice = o.OrderSum 
		FROM
			(SELECT TOP 1
			o.OrderID,
			SUM((1 - od.Discount) * od.UnitPrice * od.Quantity) AS OrderSum
			FROM Orders o
			JOIN [Order Details] od ON o.OrderID = od.OrderID
			WHERE EmployeeID = @number AND YEAR(o.OrderDate) = @year
			GROUP BY o.OrderID
			ORDER BY OrderSum DESC) o

		INSERT INTO #employeesWithBiggestOrders ([Employee name], [Order number], OrderPrice)
		VALUES (@name, @orderId, @orderPrice)
		FETCH NEXT FROM employers_cursor INTO @number, @name;
	END
	CLOSE employers_cursor;  
	DEALLOCATE employers_cursor;

	SELECT TOP(@recordNumber) * 
	FROM #employeesWithBiggestOrders e
	ORDER BY e.OrderPrice DESC

END

/*
2. �������� ���������, ������� ���������� ������ � ������� Orders,
�������� ���������� ����� �������� � ���� (������� ����� OrderDate �
ShippedDate).
� ����������� ������ ���� ���������� ������, ���� ������� ���������
���������� �������� ��� ��� �������������� ������.
�������� �� ��������� ��� ������������� ����� 35 ����.
�������� ��������� ShippedOrdersDiff.
��������� ������ ����������� ��������� �������: OrderID, OrderDate,
ShippedDate, ShippedDelay (�������� � ���� ����� ShippedDate � OrderDate),
SpecifiedDelay (���������� � ��������� ��������).
���������� ������������������ ������������� ���� ���������.
*/

GO

CREATE OR ALTER PROCEDURE ShippedOrdersDiff
	@period INT = 35
AS	
BEGIN
	SELECT 
	o.OrderID,
	o.OrderDate,
	o.ShippedDate,
	DATEDIFF(DAY, OrderDate, ShippedDate) AS ShippedDelay,
	@period AS SpecifiedDelay
	FROM dbo.Orders o
	WHERE o.ShippedDate IS NULL OR DATEDIFF(DAY, OrderDate, ShippedDate) > @period
END

/*
3. �������� �������, ������� ����������, ���� �� � �������� �����������.
���������� ��� ������ BIT. � �������� �������� ��������� ������� ������������
EmployeeID. �������� ������� IsBoss.
������������������ ������������� ������� ��� ���� ��������� �� �������
Employees.
*/

GO
CREATE OR ALTER FUNCTION IsBoss(@employeeID int)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT 1 FROM dbo.Employees WHERE ReportsTo = @employeeID)
		RETURN 1;
	RETURN 0;
END

/*
4. �������� ������, ������� ������ ������� ��������� ����:
� OrderID (dbo.Orders),
� CustomerID (dbo.Orders),
� LastName + FirstName (dbo.Employees),
� OrderDate (dbo.Orders),
� RequiredDate (dbo.Orders),
� ProductName (dbo.Products),
� ���� ������ � ������ ������.
�
��������� ������� ���������� ����������� � ���� �������������.
*/
GO

CREATE OR ALTER VIEW OrdersWithEmployeesAndProducts AS
SELECT
	o.OrderID, o.CustomerID, e.LastName + e.FirstName as [Name], 
	o.OrderDate, o.RequiredDate, p.ProductName,
	(1 - od.Discount) * od.UnitPrice * od.Quantity AS OrderPrice
FROM dbo.Orders o
	JOIN dbo.Employees e on e.EmployeeID = o.EmployeeID
	JOIN dbo.[Order Details] od on od.OrderID = o.OrderID
	JOIN dbo.Products p on p.ProductID = od.ProductID

GO

/*
5. ������� ������� dbo.OrdersHistory, ������� ����� ������� �������
��������� �� ������� dbo.Orders.
���������� �������� ����� �� ���� ����� �� ��������� ������ �������.
���������� ���� �����. ������ ������ ����� ����� ����� ������ ���� �
������� dbo.OrdersHistory?
����� ��� ������� dbo.Orders ���������� ������� �������, ������� ��� �����
��������� ������ � ������� dbo.Orders ����� ���������� �������� � �����
������� dbo.OrdersHistory.
�������� ����������� ������, ������� ����� ��������/������� ������ ��
������� dbo.Orders.
*/

IF EXISTS(
	SELECT TOP(1) 1
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = N'OrdersHistory' AND TABLE_SCHEMA = 'dbo'
)
DROP TABLE dbo.OrdersHistory
CREATE TABLE dbo.OrdersHistory (
	Id INT IDENTITY(1, 1)	NOT NULL,
	OrderId	INT NOT NULL,
	[Changes] varchar(max)
)

GO
CREATE OR ALTER TRIGGER Orders_INSERT
ON dbo.Orders
AFTER INSERT
AS
BEGIN

	DECLARE @fieldName VARCHAR(200)
	DECLARE @resultStr VARCHAR(2000) = N''

	SELECT * 
	INTO #inserted 
	FROM inserted --��� ����������� �������� ������ � �������� �� ������������� ����

	DECLARE fields_cursor CURSOR FOR
		SELECT column_name 
		FROM INFORMATION_SCHEMA.columns 
		WHERE TABLE_NAME = 'Orders'

	OPEN fields_cursor
	FETCH NEXT FROM fields_cursor INTO @fieldName;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @fieldValue VARCHAR(2000)
		DECLARE @sql NVARCHAR(MAX) = N'SELECT @fieldValueOUT = CONVERT(VARCHAR(2000),' + @fieldName + N') FROM  #inserted'
		EXEC SP_EXECUTESQL @sql, N'@fieldValueOUT VARCHAR(2000) OUTPUT', @fieldValueOUT = @fieldValue OUTPUT
		SELECT @resultStr = @resultStr + ' ' + @fieldName + ' = ' + @fieldValue + ';'
		FETCH NEXT FROM fields_cursor INTO @fieldName;
	END
	CLOSE fields_cursor
	DEALLOCATE fields_cursor
	SELECT @resultStr = N'Created: ' + @resultStr
	INSERT INTO dbo.OrdersHistory (OrderId, [Changes]) 
	VALUES (
		(SELECT OrderID FROM inserted),
		@resultStr
	)
END

GO

CREATE OR ALTER TRIGGER Orders_UPDATE
ON dbo.Orders
AFTER UPDATE
AS
BEGIN
	DECLARE @fieldName VARCHAR(200)
	DECLARE @resultStr VARCHAR(2000) = N''

	SELECT * 
	INTO #inserted 
	FROM inserted 

	SELECT * 
	INTO #deleted 
	FROM deleted

	DECLARE fields_cursor CURSOR FOR
		SELECT column_name 
		FROM INFORMATION_SCHEMA.columns 
		WHERE TABLE_NAME = 'Orders'

	OPEN fields_cursor
	FETCH NEXT FROM fields_cursor INTO @fieldName;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @newFieldValue VARCHAR(2000)
		DECLARE @oldFieldValue VARCHAR(2000)

		DECLARE @sqlNewVal NVARCHAR(MAX) = N'SELECT @newFieldValueOUT = CONVERT(VARCHAR(2000),' + @fieldName + N') FROM  #inserted'
		EXEC SP_EXECUTESQL @sqlNewVal, N'@newFieldValueOUT VARCHAR(2000) OUTPUT', @newFieldValueOUT = @newFieldValue OUTPUT

		DECLARE @sqlOldVal NVARCHAR(MAX) = N'SELECT @oldFieldValueOUT = CONVERT(VARCHAR(2000),' + @fieldName + N') FROM  #deleted'
		EXEC SP_EXECUTESQL @sqlOldVal, N'@oldFieldValueOUT VARCHAR(2000) OUTPUT', @oldFieldValueOUT = @oldFieldValue OUTPUT

		IF @newFieldValue <> @oldFieldValue
			SELECT @resultStr = @resultStr + N' ' + @fieldName + N' = ' + @newFieldValue + N';'

		FETCH NEXT FROM fields_cursor INTO @fieldName;
	END
	CLOSE fields_cursor
	DEALLOCATE fields_cursor

	IF @resultStr <> N''
	BEGIN
		SELECT @resultStr = N'Updated: ' + @resultStr
		INSERT INTO dbo.OrdersHistory (OrderId, [Changes]) 
		VALUES (
			(SELECT OrderID FROM inserted),
			@resultStr
		)
	END
END

GO
CREATE OR ALTER TRIGGER Orders_DELETE
ON dbo.Orders
AFTER DELETE
AS
BEGIN
	INSERT INTO dbo.OrdersHistory (OrderId, [Changes]) 
	VALUES (
		(SELECT OrderID FROM deleted),
		N'Deleted'
	)
END

--����������� ������� � ������ �����