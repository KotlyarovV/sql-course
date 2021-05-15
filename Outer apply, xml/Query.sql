USE Northwind

/*
10.1. Дано
1) таблица с активами: Assets(AssetID, AssetName, Nominal, ClientPrice)
2) таблица с ценами активов на каждый день: Prices (AssetID, PriceDate, Price,
ClientPrice).
Необходимо разработать хранимую процедуру, которая на вход принимает дату.
В хранимой процедуцре должно обновлятся поле ClientPrice таблицы Assets по
данным из таблицы Prices. Если на указанную дату в тблице Prices поле ClientPrice = 0
или NULL, то нужно взять заполненное значение поля ClientPrice (ClientPrice > 0) на
ближайшую дату, предшествующую указанной на входе процедуры.
Необходимо использовать outer apply или cross apply.
*/

DROP TABLE Assets
DROP TABLE Prices

CREATE TABLE Assets (
	AssetID INT,
	AssetName VARCHAR(255),
	Nominal DECIMAL(10, 2),
	ClientPrice DECIMAL(10, 2)
)

CREATE TABLE Prices (
	AssetID INT,
	PriceDate DATE,
	Price DECIMAL(10, 2),
	ClientPrice DECIMAL(10, 2) null 
)

INSERT INTO Assets VALUES (1, 'Акции', 66, null)

INSERT INTO Prices VALUES (1, '2020-01-01', 8.90, 13.65)
INSERT INTO Prices VALUES (1, '2020-01-02', 8.90, 16.65)
INSERT INTO Prices VALUES (1, '2020-01-03', 8.90, 19.65)

GO

CREATE OR ALTER FUNCTION getClientPrice(@assetId INT, @priceDate DATE)
RETURNS DECIMAL(10, 2)
AS
BEGIN
	DECLARE @result DECIMAL(10, 2)

	IF EXISTS(
			SELECT * 
			FROM Prices p 
			WHERE p.AssetID = @assetId 
			AND p.PriceDate = @priceDate 
			AND p.ClientPrice is not null
			AND p.ClientPrice > 0)
		BEGIN
			SELECT @result = p.ClientPrice 
			FROM Prices p 
			WHERE p.AssetID = @assetId 
			AND p.PriceDate = @priceDate 
		END
	ELSE
		BEGIN
			SELECT TOP 1 @result = p.ClientPrice 
			FROM Prices p 
			WHERE p.AssetID = @assetId 
			AND p.ClientPrice IS NOT NULL
			AND p.ClientPrice > 0
			AND p.PriceDate < @priceDate
			ORDER BY p.PriceDate DESC
		END
	RETURN @result
END

GO

CREATE OR ALTER PROCEDURE SetClientPrice 
@date DATE
AS
BEGIN
	UPDATE Assets 
	SET ClientPrice = p.Price
	FROM Assets a
	CROSS APPLY (SELECT dbo.getClientPrice(a.AssetID, @date) AS Price) AS p
END;

EXEC dbo.SetClientPrice '2020-01-06'
SELECT * FROM Assets

/*
10.2.
Необходимо написать хранимую процедуру, на вход которой передается XML и в
которой в рамках одной транзакции заполняются таблицы Categories и Products базы
данных Northwind. Задание выполнить не используя курсоры и циклы.
Для упрощения поле SupplierID таблицы Products не заполняем.
*/

DECLARE @xml XML

SET @xml = 
'<Categories>
<Category CategoryName="MyCategory_1" Description="My first category description">
<Products ProductName="Old tee" QuantityPerUnit="1 kg pkg." UnitPrice="10.00"
 UnitsInStock="22" UnitsOnOrder="0" ReorderLevel="5" Discontinued="1"/>
<Products ProductName="Fresh tee" QuantityPerUnit="2 kg pkg." UnitPrice="20.00"
 UnitsInStock="120" UnitsOnOrder="0" ReorderLevel="25"
Discontinued="0"/>
<Products ProductName="Gold tee" QuantityPerUnit="3 kg pkg." UnitPrice="150.00"
 UnitsInStock="3" UnitsOnOrder="0" ReorderLevel="0" Discontinued="0"/>
</Category>
<Category CategoryName="MyCategory_2" Description="My second category description">
<Products ProductName="Small clock" QuantityPerUnit="12 boxes" UnitPrice="13.00"
 UnitsInStock="7" UnitsOnOrder="0" ReorderLevel="0" Discontinued="0"/>
<Products ProductName="Middle clock" QuantityPerUnit="12 boxes"
 UnitPrice="17.00" UnitsInStock="3" UnitsOnOrder="4" ReorderLevel="5"
Discontinued="1"/>
<Products ProductName="Big clock" QuantityPerUnit="12 boxes" UnitPrice="21.00"
 UnitsInStock="5" UnitsOnOrder="0" ReorderLevel="10" Discontinued="0"/>
<Products ProductName="Broken clock" QuantityPerUnit="12 boxes" UnitPrice="1.50"
 UnitsInStock="2" UnitsOnOrder="0" ReorderLevel="0" Discontinued="0"/>
</Category>
<Category CategoryName="MyCategory_3" Description="My third category description">
<Products ProductName="Yellow car" QuantityPerUnit="1 pies" UnitPrice="2000.00"
 UnitsInStock="2" UnitsOnOrder="0" ReorderLevel="0" Discontinued="0"/>
<Products ProductName="Red car" QuantityPerUnit="1 pies" UnitPrice="5000.00"
 UnitsInStock="4" UnitsOnOrder="1" ReorderLevel="5" Discontinued="0"/>
</Category>
</Categories>'

DECLARE @hDoc AS INT, @SQL NVARCHAR (MAX)

EXEC sp_xml_preparedocument @hDoc OUTPUT, @xml

SELECT 
	CategoryName, Description, ProductName, 
	QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder,
	ReorderLevel, Discontinued
INTO #tmp
FROM OPENXML(@hDoc, 'Categories/Category/Products')
WITH 
(
	CategoryName VARCHAR(50) '../@CategoryName',
	Description VARCHAR(100) '../@Description',
	ProductName VARCHAR(100) '@ProductName',
	QuantityPerUnit VARCHAR(1000) '@QuantityPerUnit',
	UnitPrice MONEY '@UnitPrice',
	UnitsInStock SMALLINT '@UnitsInStock',
	UnitsOnOrder SMALLINT '@UnitsOnOrder',
	ReorderLevel SMALLINT '@ReorderLevel',
	Discontinued BIT '@Discontinued'
)


EXEC sp_xml_removedocument @hDoc

BEGIN TRANSACTION

INSERT dbo.Categories (CategoryName, Description)
SELECT CategoryName, Description 
FROM #tmp
GROUP BY CategoryName, Description

INSERT dbo.Products (
	ProductName, CategoryID, 
	QuantityPerUnit, UnitPrice, 
	UnitsInStock, UnitsOnOrder, 
	ReorderLevel, Discontinued)
SELECT t.ProductName, c.CategoryID, 
	t.QuantityPerUnit, t.UnitPrice, 
	t.UnitsInStock, t.UnitsOnOrder, 
	t.ReorderLevel, t.Discontinued 
FROM #tmp t
JOIN dbo.Categories c ON c.CategoryName = t.CategoryName

COMMIT TRANSACTION	
GO