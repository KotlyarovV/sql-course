USE Northwind

/*
4.1.1.Написать запрос, который добавляет новый заказ в таблицу dbo.Orders
Необходимо написать два запроса
первый с использованием Values;
второй с использованием Select.
*/

--1
INSERT INTO dbo.Orders 
	(CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry) 
VALUES 
	(N'VINET', 6, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.55, N'Que Delícia', N'Rua da Panificadora, 13', N'Rio de Janeiro', N'RJ', '02389-673', 'Brazil');

GO

--2
INSERT INTO dbo.Orders 
	(CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
SELECT 
	N'VINET', 6, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.55, N'Que Delícia', N'Rua da Panificadora, 13', N'Rio de Janeiro', N'RJ', '02389-673', 'Brazil';

GO

/*
4.1.2.Написать запрос, который добавляет 5 новых заказов в таблицу dbo.Orders
Необходимо написать два запроса
первый с использованием Values;
второй с использованием Select.
*/

--1

INSERT INTO dbo.Orders 
	(CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry) 
VALUES 
	(N'VINET', 6, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.55, N'Que Delícia', N'Any street, 13', N'Paris', N'PR', '029-673', N'France'),
	(N'VINET', 2, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	4.55, N'Que Delícia', N'Lenina str 12', N'Pervouralsk', N'PRV', '666-673', N'Russia'),
	(N'VINET', 1, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	2.55, N'Something', N'Some street, 13', N'Rio de Janeiro', N'RJ', '02389-673', N'Brazil'),
	(N'VINET', 4, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	5.55, N'Que Delícia', N'Rua da Panificadora, 15', N'Rio de Janeiro', N'RJ', '02389-673', N'Brazil'),
	(N'VINET', 3, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	7.55, N'Que Delícia', N'Nevsky', N'Sankt peterburg', N'STP', '02389-673', N'Russia');

GO

--2

INSERT INTO dbo.Orders 
	(CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
SELECT 
	N'VINET', 1, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.55, N'Que Delícia', N'Rua da Panificadora, 10', N'Rio de Janeiro', N'RJ', '02389-673', N'Brazil'
UNION ALL
SELECT 
	N'VINET', 2, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	9.11, N'Ship name 11', N'Baker str, 221B', N'London', N'LN', '02389-673', N'Britain'
UNION ALL
SELECT 
	N'VINET', 3, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.52, N'Ship name 2', N'Syromolotova, 16', N'Ekaterinburg', N'EKB', '333-673', N'Russia'
UNION ALL
SELECT 
	N'VINET', 4, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	9.11, N'Ship name 11', N'Baker str, 13', N'London', N'LN', '02389-673', N'Britain'
UNION ALL
SELECT 
	N'VINET', 5, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.55, N'Ship name 1', N'Rua da Panificadora, 13', N'Rio de Janeiro', N'RJ', '02389-673', N'Brazil';

GO

/*
4.1.3.Написать запрос, который добавляет в таблицу dbo.Orders дублирующие
заказы по CustomerID = ‘WARTH’ и продавцу EmployeeID = 5 (заменить
CustomerID на ‘TOMSP’).
*/

INSERT INTO dbo.Orders 
	(CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
SELECT
	N'TOMSP', EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
FROM dbo.Orders
WHERE CustomerID = N'WARTH' and EmployeeID = 5;

GO

/*
4.1.4.Написать запрос, который обновит по всем заказам дату ShippedDate
(которые еще не доставлены) на текущую дату
*/

UPDATE dbo.Orders
SET ShippedDate = GETDATE()
WHERE
ShippedDate is NULL;

GO

/*
4.1.5.Написать запрос, который обновит скидку на произвольное значение (поле
Discount таблицы dbo.[Order Details]) по заказам, где CustomerID = ‘GODOS’
по продукту ‘Tarte au sucre’.
*/

UPDATE dbo.[Order Details]
SET Discount = RAND()
WHERE 
OrderID in (
	SELECT OrderID 
	FROM dbo.Orders o 
	WHERE o.CustomerID = N'GODOS') 
and
ProductID in (
	SELECT ProductID 
	FROM dbo.Products p 
	WHERE p.ProductName = N'Tarte au sucre');

GO

/*
4.1.6.Написать запрос, который удалит заказы, по которым сумма заказа меньше
20.
-
*/

DECLARE @DeletedIds TABLE (
	OrderId INT
);

INSERT INTO @DeletedIds
SELECT od.OrderID
FROM dbo.[Order Details] od
GROUP BY od.OrderID
HAVING SUM((1 - od.Discount) * od.UnitPrice * od.Quantity) < 20

DELETE FROM dbo.[Order Details]
WHERE OrderID in (
	SELECT OrderId 
	FROM @DeletedIds);

DELETE FROM dbo.[Orders]
WHERE OrderID in (
	SELECT OrderId 
	FROM @DeletedIds);

GO

/*
4.2.1. Необходимо создать и заполнить две временные таблицы:
#tblBook – содержит информацию о книгах, которые есть в библиотеке#tblBookInLibrary – содержит информацию о дате регистрации по
некоторым книгам в библиотеке*/IF OBJECT_ID('TEMPDB..#tblBook') IS NOT NULL DROP TABLE #tblBook
	CREATE TABLE #tblBook (
		BookID INT PRIMARY KEY IDENTITY(1, 1),
		Name varchar(100)
);

IF OBJECT_ID('TEMPDB..#tblBookInLibrary') IS NOT NULL DROP TABLE #tblBookInLibrary
	CREATE TABLE #tblBookInLibrary (
		BookID INT,
		Date DATE
);

INSERT INTO #tblBook (Name)
VALUES 
(N'Война и мир'), (N'Преступление и наказание'), (N'Мастер и маргарита'), (N'Тихий дон');

INSERT INTO #tblBookInLibrary 
VALUES
(1, '2006-05-01'),
(3, '2004-07-05');

GO

/*
Запрос 1. Выбрать все книги, а поле дата должно быть заполнено только у
тех книг,
у которых дата регистрации больше 01.02.2005
*/

SELECT b.Name, bil.Date FROM #tblBook b
LEFT JOIN #tblBookInLibrary bil 
ON b.BookID = bil.BookID;

GO
/*
Запрос 2. Выбрать все книги у которых дата регистрации в библиотеке
больше 01.02.2005, либо не задана вообще.*/SELECT b.Name FROM #tblBook b
LEFT JOIN #tblBookInLibrary bil 
ON b.BookID = bil.BookID
WHERE bil.Date is NULL or bil.Date > '2005-02-01';

GO