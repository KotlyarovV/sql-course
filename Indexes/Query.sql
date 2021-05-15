USE Northwind

/*
9.1. Ќаписать скрипт, который обновит в поле PostalCode таблицы
dbo.Employees все не числовые символы на любые числовые.
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
9.2. ѕостроить план и оптимизировать запрос, представленный ниже, так
чтобы индекс индекс PostalCode работал не по табличному сканированию
(Index Scan), а по Index Seek. Ќеобходимо по€снить, почему вы
оптимизировали запрос именно так?
SELECT EmployeeID
FROM dbo.Employees
WHERE LEFT(PostalCode, 2) = '98'
*/

--до оптимизации
SELECT EmployeeID
FROM dbo.Employees
WHERE LEFT(PostalCode, 2) = '98'

--после
SELECT EmployeeID
FROM dbo.Employees
WHERE PostalCode LIKE '98%'

/*
—кал€рные функции T-SQL (в данном случае это left) мешают использованию индекса
ѕри смене варианта поиска на like с началом строки стало возможно использовать индекс
*/

/*
9.3. –азобратьс€ с планом запроса, представленного ниже скрипта.
ќптимизировать запрос. ѕо€снить подробно почему вы считаете, что ваш
вариант оптимизации наиболее оптимизирует данный запрос и увеличит
его быстродействие?
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
ƒл€ проверки быстродействи€ необходимо вставить в задействованные
таблицы 1000000+ записей. 
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
ѕосле добавлени€ в таблицы запроса большого числа записей
те из перечисленных join ов, что относились к увеличенным таблицам
начали работать через index seek, а не через index scan.

“.к. Order detail содержит индекс по OrderID и по ProductID -
в случае увеличени€ этой таблицы задействованны будут и они

¬ качестве оптимизации было выбрано создать индекс по CustimerID и CompanyName,
чтобы ускорить извлечение CompanyName из базы и создание индеса дл€ Employee
по LastName, FirstName.

ќстальные были добавлены в базу при создании
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
