USE Northwind
GO
/*
1. ������� ����� ����� <����� �����> � ������������ �� Northwind.
��������� ���������� � ������ �������� �����.
*/
IF (SCHEMA_ID('new_schema') IS NULL)
	EXEC('CREATE SCHEMA new_schema')

GO
/*
2. � <����� �����> ������� �������
a. Orders
b. Order Details
c. Products
d. Categories (��� ���� Picture)
e. Customers
��������� ���� ������ ����������� ��������� ��������� ������ � �����
dbo. ���������� ���������� ���������� �������� IDENTITY �
�������������� �����. ��� ����������� � ����� ����� ���������.
��������� ���������� � ������ �������� ������ � ������������
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
3. �������� �������� ��������� � ����� dbo, ������� �� ���� ��������
��������� ���� XML � ������� ��������������� ������� (OrderID).
�������� ��������� �������� XML � ����������� � ������� �� ������
���������� ���������������.
XML ������ ��������� ����������, ����������� ��� ����������
������ Orders, Order Details, Products, Categories, Customers.

!!� ������� ���� ������ - ������ ����� �� ���������������� ��������� ����������
xml � ����������� � �������, �������������� ������� ���� �� �������� � �����������,
����������� ��� ���������� ������ ������ �����

*/
--� ������ �����

/*
4. �������� �������� ��������� � <����� �����>, ������� �� ���� ��������
XML � ����������� � �������. ��������� ������������ ���������� ��
XML � ��������� ������ � ������� � �������� �� <����� �����>.
���������� ������, ���
a. ����� ����� ���� ����� ��� ����������
b. ����� ���������� ��������� ������
c. ������ ������ ����� ���� ���������, ������� ��� ��������
��������� ������.
d. ��������, ���������, ���������� ����� ���� ������ ��� �����
��������� ��������� ������������.
*/
--� ������ �����

/*
5. �������� �������� ��������� � <����� �����>, ����������� ��������� ��
�.4.
����������� ���� ���������:
a. �� ���� ���������� ������, ���������� XML, � �� ��� XML.
b. �������� ��������� ������ ������������ OpenXML � ��
����������� ��� XML.
*/
--� ������ �����


/*
6. �������� �������� ��������� � ����� dbo, ����������� ��������� �� �.3.
����������� ���� ���������:
a. �� ���� ���������� ����� ��������������� ������� � ����
���������� ���������� ����.
b. ����������� ���������� �������� ��������� ������ ���� JSON �
�����������, ����������� ��� ���������� ������ Orders, Order
Details, Products, Categories, Customers
*/
--� ������ �����

/*
7. �������� �������� ��������� � <����� �����>, ����������� ��������� ��
�.5.
����������� ���� ���������:
a. �� ���� ���������� ������, ���������� JSON.
b. �������� ��������� ���������� JSON ������ OpenXML.
*/
--� ������ �����

/*
8. �������� ������� ������ �������� ��������, ���������� ����.
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
9. �������� ������������������ �������� �������� �� �.3 � �.6.10. �������� ������������������ �������� �������� �� �.4, �.5 � �.7*/DECLARE @newOrderNumbers XML;SET @newOrderNumbers = '<OrderNumbers><Number number="10248"/><Number number="10249"/><Number number="10250"/></OrderNumbers>'
DECLARE @newOrderInfoRes XML
EXEC dbo.createXml @newOrderNumbers,  @orderInfo=@newOrderInfoRes OUTPUT;

EXEC [new_schema].fillFromXml @newOrderInfoRes

DECLARE @newOrderXmlStr VARCHAR(MAX)
SET @newOrderXmlStr = CONVERT(VARCHAR(MAX), @newOrderInfoRes)
EXEC [new_schema].fillFromStrWithOpenXML @newOrderXmlStr
/*
��� createXml

SQL Server Execution Times:
   CPU time = 94 ms,  elapsed time = 95 ms.

�� ����� ���������� ������ � XML �������� 84% �������

��� fillFromXml
SQL Server Execution Times:
   CPU time = 234 ms,  elapsed time = 274 ms.
�������� ����� ���� ��������� �� ������ XML reader

��� fillFromStrWithOpenXML
SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 46 ms.
�������� ����� ��������� �� join �
*/

DECLARE @newOrderIdsTable AS OrderIdsTable
INSERT INTO @newOrderIdsTable
	VALUES (10248), (10249), (10250)
DECLARE @newOrderInfoResJson VARCHAR(MAX)
EXEC dbo.createJson @newOrderIdsTable,  @orderInfo=@newOrderInfoResJson OUTPUT;

EXEC dbo.createJson @newOrderIdsTable,  @orderInfo=@newOrderInfoResJson OUTPUT;
EXEC [new_schema].fillFromJson @newOrderInfoResJson


/*
��� createJson
 SQL Server Execution Times:
   CPU time = 32 ms,  elapsed time = 42 ms.
   ������ � json �������� ������� ����� �������, �������� ������� ���� �� ������ � join

��� fillFromJson
SQL Server Execution Times:
   CPU time = 78 ms,  elapsed time = 90 ms.
   ������ � openjson �������� ������� ����� �������, �������� ������� ���� �� ������ � join
*/



