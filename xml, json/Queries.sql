USE Northwind
GO
/*
1. Создать новую схему <Новая схема> в существующей БД Northwind.
Результат выполнения – скрипт создания схемы.
*/
IF (SCHEMA_ID('new_schema') IS NULL)
	EXEC('CREATE SCHEMA new_schema')

GO
/*
2. В <Новая схема> создать таблицы
a. Orders
b. Order Details
c. Products
d. Categories (без поля Picture)
e. Customers
Структура этих таблиц практически идентична структуре таблиц в схеме
dbo. Исключение сотсавляет отключение свойства IDENTITY у
соответсвующих полей. Все ограничения и ключи также совпадают.
Результат выполнения – скрипт создания таблиц и констрейнтов
*/

IF OBJECT_ID('[new_schema].[Customers]') IS NULL
CREATE TABLE [new_schema].[Customers](
	[CustomerID] [nchar](5) NOT NULL PRIMARY KEY,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
)

IF OBJECT_ID('[new_schema].[Categories]') IS NULL
CREATE TABLE [new_schema].[Categories](
	[CategoryID] [int] NOT NULL PRIMARY KEY,
	[CategoryName] [nvarchar](15) NOT NULL,
	[Description] [ntext] NULL
)

IF OBJECT_ID('[new_schema].[Orders]') IS NULL
CREATE TABLE [new_schema].[Orders](
	[OrderID] [int] NOT NULL primary key,
	[CustomerID] [nchar](5) NULL FOREIGN KEY REFERENCES [new_schema].[Customers] ([CustomerID]),
	[EmployeeID] [int] NULL,
	[OrderDate] [datetime] NULL,
	[RequiredDate] [datetime] NULL,
	[ShippedDate] [datetime] NULL,
	[ShipVia] [int] NULL,
	[Freight] [money] NULL DEFAULT ((0)),
	[ShipName] [nvarchar](40) NULL,
	[ShipAddress] [nvarchar](60) NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipRegion] [nvarchar](15) NULL,
	[ShipPostalCode] [nvarchar](10) NULL,
	[ShipCountry] [nvarchar](15) NULL,
	[OrderNum] [bigint] NULL,
	[GroupMonthNum] [bigint] NULL)

IF OBJECT_ID('[new_schema].[Products]') IS NULL
CREATE TABLE [new_schema].[Products](
	[ProductID] [int] NOT NULL PRIMARY KEY,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL FOREIGN KEY REFERENCES [new_schema].[Categories] ([CategoryID]),
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL,
)

IF OBJECT_ID('[new_schema].[Order Details]') IS NULL
CREATE TABLE [new_schema].[Order Details](
	[OrderID] [int] NOT NULL FOREIGN KEY REFERENCES [new_schema].[Orders] ([OrderID]),
	[ProductID] [int] NOT NULL FOREIGN KEY REFERENCES [new_schema].[Products] ([ProductID]),
	[UnitPrice] [money] NOT NULL DEFAULT ((0)),
	[Quantity] [smallint] NOT NULL DEFAULT ((1)),
	[Discount] [real] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK_Order_Details] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[ProductID] ASC
))

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
--в другом файле

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
--в другом файле

/*
5. Написать хранимую процедуру в <Новая схема>, аналогичную процедуре из
п.4.
Особенности этой процедуры:
a. На вход передается строка, содержащая XML, а не тип XML.
b. Хранимая процедура должна использовать OpenXML и не
испоьзовать тип XML.
*/
--в другом файле


/*
6. Написать хранимую процедуру в схеме dbo, аналогичную процедуре из п.3.
Особенности этой процедуры:
a. На вход передается набор идентификаторов заказов в виде
переменной табличного типа.
b. Результатом выполнения хранимой процедуры должен быть JSON с
информацией, необходимой для заполнения таблиц Orders, Order
Details, Products, Categories, Customers
*/
--в другом файле

/*
7. Написать хранимую процедуру в <Новая схема>, аналогичную процедуре из
п.5.
Особенности этой процедуры:
a. На вход передается строка, содержащая JSON.
b. Хранимая процедура использует JSON вместо OpenXML.
*/
--в другом файле

/*
8. Привести примеры вызова хранимых процедур, написанных выше.
*/

DECLARE @orderNumbers XML;
SET @orderNumbers = '<OrderNumbers><Number number="10248"/><Number number="10249"/><Number number="10250"/></OrderNumbers>'
DECLARE @orderInfoRes XML

EXEC dbo.createXml @orderNumbers,  @orderInfo=@orderInfoRes OUTPUT;
EXEC [new_schema].fillFromXml @orderInfoRes

DECLARE @orderXmlStr VARCHAR(MAX)
SET @orderXmlStr = CONVERT(VARCHAR(MAX), @orderInfoRes)
EXEC [new_schema].fillFromStrWithOpenXML @orderXmlStr

DECLARE @OrderIdsTable AS OrderIdsTable
INSERT INTO @OrderIdsTable
	VALUES (10248), (10249), (10250)
DECLARE @orderInfoResJson VARCHAR(MAX)
EXEC dbo.createJson @OrderIdsTable,  @orderInfo=@orderInfoResJson OUTPUT;
EXEC [new_schema].fillFromJson @orderInfoResJson

/*
9. Сравнить производительность хранимых процедур из п.3 и п.6.10. Сравнить производительность хранимых процедур из п.4, п.5 и п.7*/DECLARE @newOrderNumbers XML;SET @newOrderNumbers = '<OrderNumbers><Number number="10248"/><Number number="10249"/><Number number="10250"/></OrderNumbers>'
DECLARE @newOrderInfoRes XML
EXEC dbo.createXml @newOrderNumbers,  @orderInfo=@newOrderInfoRes OUTPUT;

EXEC [new_schema].fillFromXml @newOrderInfoRes

DECLARE @newOrderXmlStr VARCHAR(MAX)
SET @newOrderXmlStr = CONVERT(VARCHAR(MAX), @newOrderInfoRes)
EXEC [new_schema].fillFromStrWithOpenXML @newOrderXmlStr
/*
для createXml

SQL Server Execution Times:
   CPU time = 94 ms,  elapsed time = 95 ms.

по плану выполнения работа с XML занимает 84% запроса

для fillFromXml
SQL Server Execution Times:
   CPU time = 234 ms,  elapsed time = 274 ms.
основное время было затрачено на работу XML reader

для fillFromStrWithOpenXML
SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 46 ms.
основное время затрачено на join ы
*/

DECLARE @newOrderIdsTable AS OrderIdsTable
INSERT INTO @newOrderIdsTable
	VALUES (10248), (10249), (10250)
DECLARE @newOrderInfoResJson VARCHAR(MAX)
EXEC dbo.createJson @newOrderIdsTable,  @orderInfo=@newOrderInfoResJson OUTPUT;

EXEC dbo.createJson @newOrderIdsTable,  @orderInfo=@newOrderInfoResJson OUTPUT;
EXEC [new_schema].fillFromJson @newOrderInfoResJson


/*
для createJson
 SQL Server Execution Times:
   CPU time = 32 ms,  elapsed time = 42 ms.
   работа с json занимает меньшую часть запроса, основные расходы идут на работу с join

для fillFromJson
SQL Server Execution Times:
   CPU time = 78 ms,  elapsed time = 90 ms.
   работа с openjson занимает меньшую часть запроса, основные расходы идут на работу с join
*/



