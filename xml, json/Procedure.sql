USE Northwind

/*
3. Написать хранимую процедуру в схеме dbo, которая на вход получает
переменую типа XML с набором идентификаторов заказов (OrderID).
Хранимая процедура получает XML с информацией о заказах на основе
переданных идентификаторов.
XML должна сожержать информацию, необходимую для заполнения
таблиц Orders, Order Details, Products, Categories, Customers.

!!в задании явно ошибка - скорее всего по индентификаторам процедура ВОЗВРАЩАЕТ
xml с информацией о заказах, идентификаторы которых были ей переданы с информацией,
достаточной для заполнения таблиц другой схемы

*/

GO

CREATE OR ALTER PROCEDURE dbo.createXml
	@orderNumbers XML,
	@orderInfo XML OUTPUT
AS
BEGIN
	SET @orderInfo = (
		SELECT * 
		FROM dbo.Orders o
		JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
		JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
		JOIN dbo.Products p ON p.ProductID = od.ProductID
		JOIN dbo.Categories ca ON ca.CategoryID = p.CategoryID
		WHERE o.OrderID IN (
			SELECT 
				x.c.value('@number', 'int') 
			FROM
				@orderNumbers.nodes('/OrderNumbers/Number') x(c))
		FOR XML AUTO, ROOT('Orders'))
END
GO

/*
4. Написать хранимую процедуру в <Новая схема>, которая на вход получает
XML с информацией о заказах. Процедура обрабатывает информацию из
XML и обновляет данные о заказах в таблицах из <Новая схема>.
Необходимо учесть, что
a. Заказ может быть новым или измененным
b. Могут измениться реквизиты заказа
c. Строки заказа могут быть добавлены, удалены или изменены
реквизиты строки.
d. Продукты, категории, покупатели могут быть новыми или могут
изменится реквизиты существующих.
*/

CREATE OR ALTER PROCEDURE [new_schema].fillFromXml
	@orderInfo XML
AS
BEGIN
	;WITH cteCustomers AS (
		SELECT DISTINCT
			x.c.value('@CustomerID', '[nchar](5)') AS CustomerID,
			x.c.value('@CompanyName', '[nvarchar](40)') AS CompanyName,
			x.c.value('@ContactName', '[nvarchar](30)') AS ContactName,
			x.c.value('@ContactTitle', '[nvarchar](30)') AS ContactTitle,
			x.c.value('@Address', '[nvarchar](60)') AS Address,
			x.c.value('@City', '[nvarchar](15)') AS City,
			x.c.value('@Region', '[nvarchar](15)') AS Region,
			x.c.value('@PostalCode', '[nvarchar](10)') AS PostalCode,
			x.c.value('@Country', '[nvarchar](15)') AS Country,
			x.c.value('@Phone', '[nvarchar](24)') AS Phone,
			x.c.value('@Fax', '[nvarchar](24)') AS Fax
		FROM 
			@orderInfo.nodes('/Orders/o/c') x(c))
	MERGE INTO [new_schema].[Customers] AS c
	USING cteCustomers ON cteCustomers.CustomerID = c.CustomerID
	WHEN MATCHED THEN UPDATE SET 
		c.CompanyName = cteCustomers.CompanyName,
		c.ContactName = cteCustomers.ContactName,
		c.ContactTitle = cteCustomers.ContactTitle,
		c.Address = cteCustomers.Address,
		c.City = cteCustomers.City,
		c.Region = cteCustomers.Region,
		c.PostalCode = cteCustomers.PostalCode,
		c.Country = cteCustomers.Country,
		c.Phone = cteCustomers.Phone,
		c.Fax = cteCustomers.Fax
	WHEN NOT MATCHED
	THEN INSERT(CustomerID, CompanyName, ContactName, ContactTitle, 
		Address, City, Region, PostalCode, Country, Phone, Fax) 
	VALUES(cteCustomers.CustomerID, cteCustomers.CompanyName, 
		cteCustomers.ContactName, cteCustomers.ContactTitle, cteCustomers.Address, 
		cteCustomers.City, cteCustomers.Region, cteCustomers.PostalCode, 
		cteCustomers.Country, cteCustomers.Phone, cteCustomers.Fax);
	;WITH cteCategories AS (
		SELECT DISTINCT
			x.c.value('@CategoryID', 'int') as CategoryID,
			x.c.value('@CategoryName', '[nvarchar](15)') as CategoryName,
			x.c.value('@Description', '[NVARCHAR](MAX)') as Description
		FROM 
			@orderInfo.nodes('/Orders/o/c/od/p/ca') x(c))
	MERGE INTO [new_schema].[Categories] AS c
	USING cteCategories ON cteCategories.CategoryID = c.CategoryID
	WHEN MATCHED THEN UPDATE SET 
		c.CategoryName = cteCategories.CategoryName,
		c.Description = cteCategories.Description
	WHEN NOT MATCHED
	THEN INSERT(CategoryID, CategoryName, Description) 
	VALUES(cteCategories.CategoryID, 
		cteCategories.CategoryName, 
		cteCategories.Description);
	;WITH cteProducts AS (
		SELECT DISTINCT
			x.c.value('@ProductID', 'int') as ProductID,
			x.c.value('@ProductName', '[nvarchar](40)') as ProductName,
			x.c.value('@SupplierID', 'int') as SupplierID,
			x.c.value('@CategoryID', 'int') as CategoryID,
			x.c.value('@QuantityPerUnit', '[nvarchar](20)') as QuantityPerUnit,
			x.c.value('@UnitPrice', 'money') as UnitPrice,
			x.c.value('@UnitsInStock', 'smallint') as UnitsInStock,
			x.c.value('@UnitsOnOrder', 'smallint') as UnitsOnOrder,
			x.c.value('@ReorderLevel', 'smallint') as ReorderLevel,
			x.c.value('@Discontinued', 'bit') as Discontinued
		FROM 
			@orderInfo.nodes('/Orders/o/c/od/p') x(c))
	MERGE INTO [new_schema].[Products] AS p
	USING cteProducts ON cteProducts.ProductID = p.ProductID
	WHEN MATCHED THEN UPDATE SET 
		p.ProductName = cteProducts.ProductName,
		p.SupplierID = cteProducts.SupplierID,
		p.CategoryID = cteProducts.CategoryID,
		p.QuantityPerUnit = cteProducts.QuantityPerUnit,
		p.UnitPrice = cteProducts.UnitPrice,
		p.UnitsInStock = cteProducts.UnitsInStock,
		p.UnitsOnOrder = cteProducts.UnitsOnOrder,
		p.ReorderLevel = cteProducts.ReorderLevel,
		p.Discontinued = cteProducts.Discontinued
	WHEN NOT MATCHED 
	THEN INSERT(ProductID, ProductName, SupplierID, CategoryID, 
		QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued) 
	VALUES(cteProducts.ProductID, cteProducts.ProductName, 
		cteProducts.SupplierID, cteProducts.CategoryID, cteProducts.QuantityPerUnit, 
		cteProducts.UnitPrice, cteProducts.UnitsInStock, cteProducts.UnitsOnOrder, 
		cteProducts.ReorderLevel, cteProducts.Discontinued);

	;WITH cteOrders AS (
		SELECT DISTINCT
			x.c.value('@OrderID', 'int') as OrderID,
			x.c.value('@CustomerID', '[nchar](5)') as CustomerID,
			x.c.value('@EmployeeID', 'int') as EmployeeID,
			x.c.value('@OrderDate', 'datetime') as OrderDate,
			x.c.value('@RequiredDate', 'datetime') as RequiredDate,
			x.c.value('@ShippedDate', 'datetime') as ShippedDate,
			x.c.value('@ShipVia', 'int') as ShipVia,
			x.c.value('@Freight', 'money') as Freight,
			x.c.value('@ShipName', '[nvarchar](40)') as ShipName,
			x.c.value('@ShipAddress', '[nvarchar](60)') as ShipAddress,
			x.c.value('@ShipCity', '[nvarchar](15)') as ShipCity,
			x.c.value('@ShipRegion', '[nvarchar](15)') as ShipRegion,
			x.c.value('@ShipPostalCode', '[nvarchar](10)') as ShipPostalCode,
			x.c.value('@ShipCountry', '[nvarchar](15)') as ShipCountry,
			x.c.value('@OrderNum', 'bigint') as OrderNum,
			x.c.value('@GroupMonthNum', 'bigint') as GroupMonthNum
		FROM 
			@orderInfo.nodes('/Orders/o') x(c))
	MERGE INTO [new_schema].[Orders] AS o
	USING cteOrders ON cteOrders.OrderID = o.OrderID
	WHEN MATCHED THEN UPDATE SET 
		o.CustomerID = cteOrders.CustomerID,
		o.EmployeeID = cteOrders.EmployeeID,
		o.OrderDate = cteOrders.OrderDate,
		o.RequiredDate = cteOrders.RequiredDate,
		o.ShippedDate = cteOrders.ShippedDate,
		o.ShipVia = cteOrders.ShipVia,
		o.Freight = cteOrders.Freight,
		o.ShipName = cteOrders.ShipName,
		o.ShipAddress = cteOrders.ShipAddress,
		o.ShipCity = cteOrders.ShipCity,
		o.ShipRegion = cteOrders.ShipRegion,
		o.ShipPostalCode = cteOrders.ShipPostalCode,
		o.ShipCountry = cteOrders.ShipCountry,
		o.OrderNum = cteOrders.OrderNum,
		o.GroupMonthNum = cteOrders.GroupMonthNum
	WHEN NOT MATCHED 
	THEN INSERT(OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, 
		ShipRegion, ShipPostalCode, ShipCountry, OrderNum, GroupMonthNum) 
	VALUES(cteOrders.OrderID, cteOrders.CustomerID, cteOrders.EmployeeID, 
		cteOrders.OrderDate, cteOrders.RequiredDate, cteOrders.ShippedDate, 
		cteOrders.ShipVia, cteOrders.Freight, cteOrders.ShipName, 
		cteOrders.ShipAddress, cteOrders.ShipCity, cteOrders.ShipRegion, 
		cteOrders.ShipPostalCode, cteOrders.ShipCountry, 
		cteOrders.OrderNum, cteOrders.GroupMonthNum);
	;WITH cteOrderDetails AS (
		SELECT DISTINCT
			x.c.value('@ProductID', 'int') as ProductID,
			x.c.value('@OrderID', 'int') as OrderID,
			x.c.value('@Quantity', 'smallint') as Quantity,
			x.c.value('@UnitPrice', 'money') as UnitPrice,
			x.c.value('@Discount', 'real') as Discount
		FROM 
			@orderInfo.nodes('/Orders/o/c/od') x(c))
	MERGE INTO [new_schema].[Order Details] AS od
	USING cteOrderDetails ON cteOrderDetails.ProductID = od.ProductID AND cteOrderDetails.OrderID = od.OrderID
	WHEN MATCHED THEN UPDATE SET 
		od.Quantity = cteOrderDetails.Quantity,
		od.UnitPrice = cteOrderDetails.UnitPrice,
		od.Discount = cteOrderDetails.Discount
	WHEN NOT MATCHED 
	THEN INSERT(ProductID, OrderID, Quantity, UnitPrice, Discount) 
	VALUES(cteOrderDetails.ProductID, cteOrderDetails.OrderID, 
		cteOrderDetails.Quantity, cteOrderDetails.UnitPrice, 
		cteOrderDetails.Discount)
	WHEN NOT MATCHED BY SOURCE AND od.OrderID IN (SELECT OrderID FROM cteOrderDetails) 
	THEN DELETE;
END

GO

/*
5. Написать хранимую процедуру в <Новая схема>, аналогичную процедуре из
п.4.
Особенности этой процедуры:
a. На вход передается строка, содержащая XML, а не тип XML.
b. Хранимая процедура должна использовать OpenXML и не
испоьзовать тип XML.
*/

CREATE OR ALTER PROCEDURE [new_schema].fillFromStrWithOpenXML
	@orderInfo VARCHAR(MAX)
AS
BEGIN
	DECLARE @hDoc AS INT
	EXEC sp_xml_preparedocument @hDoc OUTPUT, @orderInfo

	;WITH cteCustomers AS (
		SELECT DISTINCT 
			CustomerID, CompanyName, ContactName, ContactTitle, 
			Address, City, Region, PostalCode, Country, Phone, Fax
		FROM OPENXML(@hDoc, '/Orders/o/c') WITH
		(
			[CustomerID] [nchar](5) '@CustomerID',
			[CompanyName] [nvarchar](40) '@CompanyName',
			[ContactName] [nvarchar](30) '@ContactName',
			[ContactTitle] [nvarchar](30) '@ContactTitle',
			[Address] [nvarchar](60) '@Address',
			[City] [nvarchar](15) '@City',
			[Region] [nvarchar](15) '@Region',
			[PostalCode] [nvarchar](10) '@PostalCode',
			[Country] [nvarchar](15) '@Country',
			[Phone] [nvarchar](24) '@Phone',
			[Fax] [nvarchar](24) '@Fax'
		))
	MERGE INTO [new_schema].[Customers] AS c
	USING cteCustomers ON cteCustomers.CustomerID = c.CustomerID
	WHEN MATCHED THEN UPDATE SET 
		c.CompanyName = cteCustomers.CompanyName,
		c.ContactName = cteCustomers.ContactName,
		c.ContactTitle = cteCustomers.ContactTitle,
		c.Address = cteCustomers.Address,
		c.City = cteCustomers.City,
		c.Region = cteCustomers.Region,
		c.PostalCode = cteCustomers.PostalCode,
		c.Country = cteCustomers.Country,
		c.Phone = cteCustomers.Phone,
		c.Fax = cteCustomers.Fax
	WHEN NOT MATCHED 
	THEN INSERT(CustomerID, CompanyName, ContactName, ContactTitle, 
		Address, City, Region, PostalCode, Country, Phone, Fax) 
	VALUES(cteCustomers.CustomerID, cteCustomers.CompanyName, 
		cteCustomers.ContactName, cteCustomers.ContactTitle, cteCustomers.Address, 
		cteCustomers.City, cteCustomers.Region, cteCustomers.PostalCode, 
		cteCustomers.Country, cteCustomers.Phone, cteCustomers.Fax);
		
	;WITH cteCategories AS (
		SELECT DISTINCT
			CategoryID, CategoryName, 
			CONVERT(VARCHAR(MAX), Description) AS Description
		FROM OPENXML(@hDoc, '/Orders/o/c/od/p/ca') WITH
		(
			[CategoryID] [int] '@CategoryID',
			[CategoryName] [nvarchar](15) '@CategoryName',
			[Description] [ntext] '@Description'
		))
	MERGE INTO [new_schema].[Categories] AS c
	USING cteCategories ON cteCategories.CategoryID = c.CategoryID
	WHEN MATCHED THEN UPDATE SET
		c.CategoryName = cteCategories.CategoryName,
		c.Description = cteCategories.Description
	WHEN NOT MATCHED
	THEN INSERT(CategoryID, CategoryName, Description) 
	VALUES(cteCategories.CategoryID, 
		cteCategories.CategoryName, 
		cteCategories.Description);
		
	;WITH cteProducts AS (
		SELECT DISTINCT 
			ProductID, ProductName, SupplierID, CategoryID, 
			QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder,
			ReorderLevel, Discontinued
		FROM OPENXML(@hDoc, '/Orders/o/c/od/p') WITH
		(
			[ProductID] [int] '@ProductID',
			[ProductName] [nvarchar](40) '@ProductName',
			[SupplierID] [int] '@SupplierID',
			[CategoryID] [int] '@CategoryID',
			[QuantityPerUnit] [nvarchar](20) '@QuantityPerUnit',
			[UnitPrice] [money] '@UnitPrice',
			[UnitsInStock] [smallint] '@UnitsInStock',
			[UnitsOnOrder] [smallint] '@UnitsOnOrder',
			[ReorderLevel] [smallint] '@ReorderLevel',
			[Discontinued] [bit] '@Discontinued'
		))
	MERGE INTO [new_schema].[Products] AS p
	USING cteProducts ON cteProducts.ProductID = p.ProductID
	WHEN MATCHED THEN UPDATE SET
		p.ProductName = cteProducts.ProductName,
		p.SupplierID = cteProducts.SupplierID,
		p.CategoryID = cteProducts.CategoryID,
		p.QuantityPerUnit = cteProducts.QuantityPerUnit,
		p.UnitPrice = cteProducts.UnitPrice,
		p.UnitsInStock = cteProducts.UnitsInStock,
		p.UnitsOnOrder = cteProducts.UnitsOnOrder,
		p.ReorderLevel = cteProducts.ReorderLevel,
		p.Discontinued = cteProducts.Discontinued
	WHEN NOT MATCHED
	THEN INSERT(ProductID, ProductName, SupplierID, CategoryID, 
		QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued) 
	VALUES(cteProducts.ProductID, cteProducts.ProductName, 
		cteProducts.SupplierID, cteProducts.CategoryID, cteProducts.QuantityPerUnit, 
		cteProducts.UnitPrice, cteProducts.UnitsInStock, cteProducts.UnitsOnOrder, 
		cteProducts.ReorderLevel, cteProducts.Discontinued);

	;WITH cteOrders AS (
		SELECT DISTINCT 
			OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
			ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, 
			ShipRegion, ShipPostalCode, ShipCountry, OrderNum, GroupMonthNum
		FROM OPENXML(@hDoc, '/Orders/o') WITH
		(
			[OrderID] [int] '@OrderID',
			[CustomerID] [nchar](5) '@CustomerID',
			[EmployeeID] [int] '@EmployeeID',
			[OrderDate] [datetime] '@OrderDate',
			[RequiredDate] [datetime] '@RequiredDate',
			[ShippedDate] [datetime] '@ShippedDate',
			[ShipVia] [int] '@ShipVia',
			[Freight] [money] '@Freight',
			[ShipName] [nvarchar](40) '@ShipName',
			[ShipAddress] [nvarchar](60) '@ShipAddress',
			[ShipCity] [nvarchar](15) '@ShipCity',
			[ShipRegion] [nvarchar](15) '@ShipRegion',
			[ShipPostalCode] [nvarchar](10) '@ShipPostalCode',
			[ShipCountry] [nvarchar](15) '@ShipCountry',
			[OrderNum] [bigint] '@OrderNum',
			[GroupMonthNum] [bigint] '@GroupMonthNum'
		))
	MERGE INTO [new_schema].[Orders] AS o
	USING cteOrders ON cteOrders.OrderID = o.OrderID
	WHEN MATCHED THEN UPDATE SET
		o.CustomerID = cteOrders.CustomerID,
		o.EmployeeID = cteOrders.EmployeeID,
		o.OrderDate = cteOrders.OrderDate,
		o.RequiredDate = cteOrders.RequiredDate,
		o.ShippedDate = cteOrders.ShippedDate,
		o.ShipVia = cteOrders.ShipVia,
		o.Freight = cteOrders.Freight,
		o.ShipName = cteOrders.ShipName,
		o.ShipAddress = cteOrders.ShipAddress,
		o.ShipCity = cteOrders.ShipCity,
		o.ShipRegion = cteOrders.ShipRegion,
		o.ShipPostalCode = cteOrders.ShipPostalCode,
		o.ShipCountry = cteOrders.ShipCountry,
		o.OrderNum = cteOrders.OrderNum,
		o.GroupMonthNum = cteOrders.GroupMonthNum
	WHEN NOT MATCHED
	THEN INSERT(OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, 
		ShipRegion, ShipPostalCode, ShipCountry, OrderNum, GroupMonthNum) 
	VALUES(cteOrders.OrderID, cteOrders.CustomerID, cteOrders.EmployeeID, 
		cteOrders.OrderDate, cteOrders.RequiredDate, cteOrders.ShippedDate, 
		cteOrders.ShipVia, cteOrders.Freight, cteOrders.ShipName, 
		cteOrders.ShipAddress, cteOrders.ShipCity, cteOrders.ShipRegion, 
		cteOrders.ShipPostalCode, cteOrders.ShipCountry, 
		cteOrders.OrderNum, cteOrders.GroupMonthNum);
		
	;WITH cteOrderDetails AS (
		SELECT DISTINCT
			ProductID, OrderID, Quantity, UnitPrice, Discount
		FROM OPENXML(@hDoc, '/Orders/o/c/od') WITH
		(
			[OrderID] [int] '@OrderID',
			[ProductID] [int] '@ProductID',
			[UnitPrice] [money] '@UnitPrice',
			[Quantity] [smallint] '@Quantity',
			[Discount] [real] '@Discount'
		))
	MERGE INTO [new_schema].[Order Details] AS od
	USING cteOrderDetails ON cteOrderDetails.ProductID = od.ProductID AND cteOrderDetails.OrderID = od.OrderID
	WHEN MATCHED THEN UPDATE SET
		od.Quantity = cteOrderDetails.Quantity,
		od.UnitPrice = cteOrderDetails.UnitPrice,
		od.Discount = cteOrderDetails.Discount
	WHEN NOT MATCHED 
	THEN INSERT(ProductID, OrderID, Quantity, UnitPrice, Discount) 
	VALUES(cteOrderDetails.ProductID, cteOrderDetails.OrderID, 
		cteOrderDetails.Quantity, cteOrderDetails.UnitPrice, 
		cteOrderDetails.Discount)
	WHEN NOT MATCHED BY SOURCE AND od.OrderID IN (SELECT OrderID FROM cteOrderDetails) 
	THEN DELETE;
		
	EXEC sp_xml_removedocument @hDoc
END

GO

/*
6. Написать хранимую процедуру в схеме dbo, аналогичную процедуре из п.3.
Особенности этой процедуры:
a. На вход передается набор идентификаторов заказов в виде
переменной табличного типа.
b. Результатом выполнения хранимой процедуры должен быть JSON с
информацией, необходимой для заполнения таблиц Orders, Order
Details, Products, Categories, Customers
*/

IF NOT EXISTS(SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'OrderIdsTable')
	CREATE TYPE OrderIdsTable 
	   AS TABLE (OrderId INT);

GO
CREATE OR ALTER PROCEDURE dbo.createJson
	@orderNumbers OrderIdsTable READONLY,
	@orderInfo NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET @orderInfo = (
		SELECT 
			o.*, c.*, od.*, p.*, 
			ca.CategoryID, ca.CategoryName, ca.Description 
		FROM dbo.Orders o
		JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
		JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
		JOIN dbo.Products p ON p.ProductID = od.ProductID
		JOIN dbo.Categories ca ON ca.CategoryID = p.CategoryID
		WHERE o.OrderID in (
			SELECT 
				OrderId 
			FROM 
				@orderNumbers)
		FOR JSON AUTO, ROOT('Orders'))
END
GO

/*
7. Написать хранимую процедуру в <Новая схема>, аналогичную процедуре из
п.5.
Особенности этой процедуры:
a. На вход передается строка, содержащая JSON.
b. Хранимая процедура использует JSON вместо OpenXML.
*/

CREATE OR ALTER PROCEDURE [new_schema].fillFromJson
	@orderInfo VARCHAR(MAX)
AS
BEGIN
	;WITH cteCustomers AS (
		SELECT DISTINCT 
			CustomerID, CompanyName, ContactName, ContactTitle, 
			Address, City, Region, PostalCode, Country, Phone, Fax
		FROM OPENJSON(@orderInfo, '$.Orders') AS o
		CROSS APPLY OPENJSON(o.value, '$.c') WITH
		(
			[CustomerID] [nchar](5) '$.CustomerID',
			[CompanyName] [nvarchar](40) '$.CompanyName',
			[ContactName] [nvarchar](30) '$.ContactName',
			[ContactTitle] [nvarchar](30) '$.ContactTitle',
			[Address] [nvarchar](60) '$.Address',
			[City] [nvarchar](15) '$.City',
			[Region] [nvarchar](15) '$.Region',
			[PostalCode] [nvarchar](10) '$.PostalCode',
			[Country] [nvarchar](15) '$.Country',
			[Phone] [nvarchar](24) '$.Phone',
			[Fax] [nvarchar](24) '$.Fax'
		))
	MERGE INTO [new_schema].[Customers] AS c
	USING cteCustomers ON cteCustomers.CustomerID = c.CustomerID
	WHEN MATCHED THEN UPDATE SET
		c.CompanyName = cteCustomers.CompanyName,
		c.ContactName = cteCustomers.ContactName,
		c.ContactTitle = cteCustomers.ContactTitle,
		c.Address = cteCustomers.Address,
		c.City = cteCustomers.City,
		c.Region = cteCustomers.Region,
		c.PostalCode = cteCustomers.PostalCode,
		c.Country = cteCustomers.Country,
		c.Phone = cteCustomers.Phone,
		c.Fax = cteCustomers.Fax
	WHEN NOT MATCHED
	THEN INSERT(CustomerID, CompanyName, ContactName, ContactTitle, 
		Address, City, Region, PostalCode, Country, Phone, Fax) 
	VALUES(cteCustomers.CustomerID, cteCustomers.CompanyName, 
		cteCustomers.ContactName, cteCustomers.ContactTitle, cteCustomers.Address, 
		cteCustomers.City, cteCustomers.Region, cteCustomers.PostalCode, 
		cteCustomers.Country, cteCustomers.Phone, cteCustomers.Fax);

	;WITH cteCategories AS (
		SELECT DISTINCT
			CategoryID, CategoryName, 
			CONVERT(VARCHAR(MAX), Description) AS Description
			FROM OPENJSON(@orderInfo, '$.Orders') AS o
			CROSS APPLY OPENJSON(o.value, '$.c') AS c
			CROSS APPLY OPENJSON(c.value, '$.od') AS od
			CROSS APPLY OPENJSON(od.value, '$.p') AS p
			CROSS APPLY OPENJSON(p.value, '$.ca') WITH
			(
				[CategoryID] [int] '$.CategoryID',
				[CategoryName] [nvarchar](15) '$.CategoryName',
				[Description] [nvarchar](max) '$.Description'
			))
	MERGE INTO [new_schema].[Categories] AS c
	USING cteCategories ON cteCategories.CategoryID = c.CategoryID
	WHEN MATCHED THEN UPDATE SET 
		c.CategoryName = cteCategories.CategoryName,
		c.Description = cteCategories.Description
	WHEN NOT MATCHED 
	THEN INSERT(CategoryID, CategoryName, Description) 
	VALUES(cteCategories.CategoryID, 
		cteCategories.CategoryName, 
		cteCategories.Description);

	;WITH cteProducts AS (
		SELECT DISTINCT 
			ProductID, ProductName, SupplierID, CategoryID, 
			QuantityPerUnit, UnitPrice, UnitsInStock, 
			UnitsOnOrder, ReorderLevel, Discontinued
		FROM OPENJSON(@orderInfo, '$.Orders') AS o
		CROSS APPLY OPENJSON(o.value, '$.c') AS c
		CROSS APPLY OPENJSON(c.value, '$.od') AS od
		CROSS APPLY OPENJSON(od.value, '$.p')  WITH
		(
			[ProductID] [int] '$.ProductID',
			[ProductName] [nvarchar](40) '$.ProductName',
			[SupplierID] [int] '$.SupplierID',
			[CategoryID] [int] '$.CategoryID',
			[QuantityPerUnit] [nvarchar](20) '$.QuantityPerUnit',
			[UnitPrice] [money] '$.UnitPrice',
			[UnitsInStock] [smallint] '$.UnitsInStock',
			[UnitsOnOrder] [smallint] '$.UnitsOnOrder',
			[ReorderLevel] [smallint] '$.ReorderLevel',
			[Discontinued] [bit] '$.Discontinued'
		))
	MERGE INTO [new_schema].[Products] AS p
	USING cteProducts ON cteProducts.ProductID = p.ProductID
	WHEN MATCHED THEN UPDATE SET 
		p.ProductName = cteProducts.ProductName,
		p.SupplierID = cteProducts.SupplierID,
		p.CategoryID = cteProducts.CategoryID,
		p.QuantityPerUnit = cteProducts.QuantityPerUnit,
		p.UnitPrice = cteProducts.UnitPrice,
		p.UnitsInStock = cteProducts.UnitsInStock,
		p.UnitsOnOrder = cteProducts.UnitsOnOrder,
		p.ReorderLevel = cteProducts.ReorderLevel,
		p.Discontinued = cteProducts.Discontinued
	WHEN NOT MATCHED 
	THEN INSERT(ProductID, ProductName, SupplierID, CategoryID, 
		QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder,
		ReorderLevel, Discontinued) 
	VALUES(cteProducts.ProductID, cteProducts.ProductName, 
		cteProducts.SupplierID, cteProducts.CategoryID, cteProducts.QuantityPerUnit, 
		cteProducts.UnitPrice, cteProducts.UnitsInStock, cteProducts.UnitsOnOrder, 
		cteProducts.ReorderLevel, cteProducts.Discontinued);

	;WITH cteOrders AS (
		SELECT DISTINCT 
			OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
			ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, 
			ShipRegion, ShipPostalCode, ShipCountry, OrderNum, GroupMonthNum
		FROM OPENJSON(@orderInfo, '$.Orders') WITH
		(
			[OrderID] [int] '$.OrderID',
			[CustomerID] [nchar](5) '$.CustomerID',
			[EmployeeID] [int] '$.EmployeeID',
			[OrderDate] [datetime] '$.OrderDate',
			[RequiredDate] [datetime] '$.RequiredDate',
			[ShippedDate] [datetime] '$.ShippedDate',
			[ShipVia] [int] '$.ShipVia',
			[Freight] [money] '$.Freight',
			[ShipName] [nvarchar](40) '$.ShipName',
			[ShipAddress] [nvarchar](60) '$.ShipAddress',
			[ShipCity] [nvarchar](15) '$.ShipCity',
			[ShipRegion] [nvarchar](15) '$.ShipRegion',
			[ShipPostalCode] [nvarchar](10) '$.ShipPostalCode',
			[ShipCountry] [nvarchar](15) '$.ShipCountry',
			[OrderNum] [bigint] '$.OrderNum',
			[GroupMonthNum] [bigint] '$.GroupMonthNum'
		))
	MERGE INTO [new_schema].[Orders] AS o
	USING cteOrders ON cteOrders.OrderID = o.OrderID
	WHEN MATCHED THEN UPDATE SET 
		o.CustomerID = cteOrders.CustomerID,
		o.EmployeeID = cteOrders.EmployeeID,
		o.OrderDate = cteOrders.OrderDate,
		o.RequiredDate = cteOrders.RequiredDate,
		o.ShippedDate = cteOrders.ShippedDate,
		o.ShipVia = cteOrders.ShipVia,
		o.Freight = cteOrders.Freight,
		o.ShipName = cteOrders.ShipName,
		o.ShipAddress = cteOrders.ShipAddress,
		o.ShipCity = cteOrders.ShipCity,
		o.ShipRegion = cteOrders.ShipRegion,
		o.ShipPostalCode = cteOrders.ShipPostalCode,
		o.ShipCountry = cteOrders.ShipCountry,
		o.OrderNum = cteOrders.OrderNum,
		o.GroupMonthNum = cteOrders.GroupMonthNum
	WHEN NOT MATCHED 
	THEN INSERT(OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, 
		ShipRegion, ShipPostalCode, ShipCountry, OrderNum, GroupMonthNum) 
	VALUES(cteOrders.OrderID, cteOrders.CustomerID, cteOrders.EmployeeID, 
		cteOrders.OrderDate, cteOrders.RequiredDate, cteOrders.ShippedDate, 
		cteOrders.ShipVia, cteOrders.Freight, cteOrders.ShipName, 
		cteOrders.ShipAddress, cteOrders.ShipCity, cteOrders.ShipRegion, 
		cteOrders.ShipPostalCode, cteOrders.ShipCountry, 
		cteOrders.OrderNum, cteOrders.GroupMonthNum);

	;WITH cteOrderDetails AS (
		SELECT DISTINCT 
			ProductID, OrderID, Quantity, UnitPrice, Discount
		FROM OPENJSON(@orderInfo, '$.Orders') AS o
		CROSS APPLY OPENJSON(o.value, '$.c') AS c
		CROSS APPLY OPENJSON(c.value, '$.od') WITH
		(
			[OrderID] [int] '$.OrderID',
			[ProductID] [int] '$.ProductID',
			[UnitPrice] [money] '$.UnitPrice',
			[Quantity] [smallint] '$.Quantity',
			[Discount] [real] '$.Discount'
		))
	MERGE INTO [new_schema].[Order Details] AS od
	USING cteOrderDetails ON cteOrderDetails.ProductID = od.ProductID AND cteOrderDetails.OrderID = od.OrderID
	WHEN MATCHED THEN UPDATE SET
		od.Quantity = cteOrderDetails.Quantity,
		od.UnitPrice = cteOrderDetails.UnitPrice,
		od.Discount = cteOrderDetails.Discount
	WHEN NOT MATCHED 
	THEN INSERT(ProductID, OrderID, Quantity, UnitPrice, Discount) 
	VALUES(cteOrderDetails.ProductID, cteOrderDetails.OrderID, 
		cteOrderDetails.Quantity, cteOrderDetails.UnitPrice, 
		cteOrderDetails.Discount)
	WHEN NOT MATCHED BY SOURCE AND od.OrderID IN (SELECT OrderID FROM cteOrderDetails) 
	THEN DELETE;
END