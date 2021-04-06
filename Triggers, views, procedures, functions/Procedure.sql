USE Northwind

/*
1. Написать процедуру, которая возвращает самый крупный заказ для
каждого из продавцов за определенный год.
В результатах не может быть несколько заказов одного продавца, должен быть
только один и самый крупный.
В результатах запроса должны быть выведены следующие колонки: колонка с
именем и фамилией продавца (FirstName и LastName – пример: Nancy Davolio),
номер заказа и его стоимость.
В запросе надо учитывать Discount при продаже товаров.
Процедуре передается год, за который надо сделать отчет, и количество
возвращаемых записей.
Результаты запроса должны быть упорядочены по убыванию суммы заказа.
Процедура должна быть реализована 2-мя способами с использованием
оператора SELECT и с использованием курсора.
Название процедур соответственно GreatestOrders и GreatestOrdersCur.
Необходимо продемонстрировать использование этих процедур. 
*/

GO

CREATE OR ALTER PROCEDURE GreatestOrders
	@year INT,
	@recordNumber INT
AS
BEGIN

SELECT TOP(@recordNumber) 
e.FirstName + ' ' + e.LastName AS [Employee name], 
MAX(o.OrderID) AS [Order number], --на случай, если заказов с максимальной суммой несколько
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
2. Написать процедуру, которая возвращает заказы в таблице Orders,
согласно указанному сроку доставки в днях (разница между OrderDate и
ShippedDate).
В результатах должны быть возвращены заказы, срок которых превышает
переданное значение или еще недоставленные заказы.
Значению по умолчанию для передаваемого срока 35 дней.
Название процедуры ShippedOrdersDiff.
Процедура должна высвечивать следующие колонки: OrderID, OrderDate,
ShippedDate, ShippedDelay (разность в днях между ShippedDate и OrderDate),
SpecifiedDelay (переданное в процедуру значение).
Необходимо продемонстрировать использование этой процедуры.
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
3. Написать функцию, которая определяет, есть ли у продавца подчиненные.
Возвращает тип данных BIT. В качестве входного параметра функции используется
EmployeeID. Название функции IsBoss.
Продемонстрировать использование функции для всех продавцов из таблицы
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
4. Написать запрос, который должен вывести следующие поля:
• OrderID (dbo.Orders),
• CustomerID (dbo.Orders),
• LastName + FirstName (dbo.Employees),
• OrderDate (dbo.Orders),
• RequiredDate (dbo.Orders),
• ProductName (dbo.Products),
• цену товара с учетом скидки.
•
Результат запроса необходимо представить в виде представления.
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
5. Создать таблицу dbo.OrdersHistory, которая будет хранить историю
изменений по таблице dbo.Orders.
Необходимо подумать какие бы поля могла бы содержать данная таблица.
Обосновать свой выбор. Почему именно такой набор полей должен быть в
таблице dbo.OrdersHistory?
Затем для таблицы dbo.Orders необходимо создать триггер, который при любом
изменении данных в таблице dbo.Orders будет записывать значения в новую
таблицу dbo.OrdersHistory.
Написать проверочный запрос, который будет изменять/удалять данные из
таблицы dbo.Orders.
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
AFTER INSERT, UPDATE
AS
BEGIN

	DECLARE @fieldName VARCHAR(200)
	DECLARE @resultStr VARCHAR(2000) = N''

	IF UPDATE(CustomerID)
		SELECT
			@resultStr = @resultStr + N'CustomerID = ' + CONVERT(VARCHAR(2000), CustomerID)
		FROM 
			INSERTED

	IF UPDATE(EmployeeID)
		SELECT
			@resultStr = @resultStr + N'EmployeeID = ' + CONVERT(VARCHAR(2000), EmployeeID)
		FROM 
			INSERTED

	IF UPDATE(OrderDate)
		SELECT
			@resultStr = @resultStr + N'OrderDate = ' + CONVERT(VARCHAR(2000), OrderDate)
		FROM 
			INSERTED

	IF UPDATE(RequiredDate)
		SELECT
			@resultStr = @resultStr + N'RequiredDate = ' + CONVERT(VARCHAR(2000), RequiredDate)
		FROM 
			INSERTED

	IF UPDATE(ShippedDate)
		SELECT
			@resultStr = @resultStr + N'ShippedDate = ' + CONVERT(VARCHAR(2000), ShippedDate)
		FROM 
			INSERTED

	IF UPDATE(ShipVia)
		SELECT
			@resultStr = @resultStr + N'ShipVia = ' + CONVERT(VARCHAR(2000), ShipVia)
		FROM 
			INSERTED

	IF UPDATE(Freight)
		SELECT
			@resultStr = @resultStr + N'Freight = ' + CONVERT(VARCHAR(2000), Freight)
		FROM 
			INSERTED

	IF UPDATE(ShipName)
		SELECT
			@resultStr = @resultStr + N'ShipName = ' + CONVERT(VARCHAR(2000), ShipName)
		FROM 
			INSERTED

	IF UPDATE(ShipAddress)
		SELECT
			@resultStr = @resultStr + N'ShipAddress = ' + CONVERT(VARCHAR(2000), ShipAddress)
		FROM 
			INSERTED

	IF UPDATE(ShipCity)
		SELECT
			@resultStr = @resultStr + N'ShipCity = ' + CONVERT(VARCHAR(2000), ShipCity)
		FROM 
			INSERTED

	IF UPDATE(ShipRegion)
		SELECT
			@resultStr = @resultStr + N'ShipRegion = ' + CONVERT(VARCHAR(2000), ShipRegion)
		FROM 
			INSERTED

	IF UPDATE(ShipPostalCode)
		SELECT
			@resultStr = @resultStr + N'ShipPostalCode = ' + CONVERT(VARCHAR(2000), ShipPostalCode)
		FROM 
			INSERTED

	IF UPDATE(ShipCountry)
		SELECT
			@resultStr = @resultStr + N'ShipCountry = ' + CONVERT(VARCHAR(2000), ShipCountry)
		FROM 
			INSERTED


	INSERT INTO dbo.OrdersHistory (OrderId, [Changes]) 
	VALUES (
		(SELECT OrderID FROM inserted),
		@resultStr
	)
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

--проверочные запросы в другом файле