USE Northwind

/*
1

Также помимо демонстрации вызовов процедур в скрипте Query.sql надо
написать отдельный ДОПОЛНИТЕЛЬНЫЙ проверочный запрос для тестирования
правильности работы процедуры GreatestOrders.
Проверочный запрос должен выводить в удобном для сравнения с результатами
работы процедур виде для определенного продавца для всех его заказов за
определенный указанный год в результатах следующие колонки: имя продавца,
номер заказа, сумму заказа.
Проверочный запрос не должен повторять запрос, написанный в процедуре, - он
должен выполнять только то, что описано в требованиях по нему.
ВСЕ ЗАПРОСЫ ПО ВЫЗОВУ ПРОЦЕДУР ДОЛЖНЫ БЫТЬ НАПИСАНЫ В ФАЙЛЕ
Query.sql*/EXEC dbo.GreatestOrders 1996, 100;EXEC dbo.GreatestOrdersCur 1996, 100;
--проверка на примере продавца с id 5 за 1996год
DECLARE @year INT = 1996;
DECLARE @employeeId INT = 5;

SELECT
	e.FirstName + N' ' +  e.LastName as [Name],
	SUM((1 - od.Discount) * od.UnitPrice * od.Quantity) AS OrderSum,
	o.OrderID
FROM dbo.Orders o
	JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
	JOIN dbo.Employees e on e.EmployeeID = o.EmployeeID
WHERE e.EmployeeID = @employeeId AND YEAR(OrderDate) = @year
GROUP BY o.OrderID, e.FirstName, e.LastName
ORDER BY OrderSumGO/*2*/EXEC dbo.ShippedOrdersDiff 34GO/*3*/SELECT dbo.IsBoss(2) AS ReasultGO--4--Отсортировать по цене товара.SELECT * FROM dbo.OrdersWithEmployeesAndProductsORDER BY OrderPriceGO--5
INSERT INTO dbo.Orders 
	(CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, 
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry) 
VALUES 
	(N'VINET', 6, N'1996-07-20 00:00:00.000', N'1996-08-16 00:00:00.000', N'1996-07-30 00:00:00.000', 2, 
	3.55, N'Que Delícia', N'Rua da Panificadora, 13', N'Rio de Janeiro', N'RJ', '02389-673', N'Brazil');

DECLARE @ID INT = (SELECT MAX(ORderID) FROM dbo.Orders)

UPDATE dbo.Orders 
SET ShipName = N'SHHHHH' 
WHERE OrderID = @ID

DELETE FROM dbo.Orders 
WHERE OrderID = @ID

SELECT * FROM dbo.OrdersHistory WHERE OrderId = @ID ORDER BY Id