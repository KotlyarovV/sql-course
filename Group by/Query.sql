USE Northwind

/*
3.1.1. Найти общую сумму всех заказов из таблицы Order Details с учетом
количества закупленных товаров и скидок по ним.
Результат округлить до сотых и высветить в стиле 1 для типа данных money.
Скидка (колонка Discount) составляет процент из стоимости для данного товара.
Для определения действительной цены на проданный продукт надо вычесть
скидку из указанной в колонке UnitPrice цены.
Результатом запроса должна быть одна запись с одной колонкой с названием
колонки 'Totals'
*/
GO

SELECT 
CONVERT(VARCHAR, SUM(CAST(UnitPrice * Quantity * (1 - Discount) AS MONEY)), 1) AS Totals
FROM dbo.[Order Details];

/*
3.1.2. По таблице Orders найти количество заказов, которые еще не были
доставлены (т.е. в колонке ShippedDate нет значения даты доставки).
Использовать при этом запросе только оператор COUNT.
Не использовать предложения WHERE и GROUP.
*/
GO

SELECT 
COUNT(*) - COUNT(ShippedDate) AS [Number of non shipped orders]
FROM dbo.Orders ;

/*
3.1.3. По таблице Orders найти количество различных покупателей (CustomerID),
сделавших заказы.
Использовать функцию COUNT и не использовать предложения WHERE и GROUP.
*/
GO

SELECT 
COUNT(DISTINCT CustomerID) AS [Customer number]
FROM dbo.Orders;

/*
3.2.1. По таблице Orders найти количество заказов с группировкой по годам.
В результатах запроса надо высвечивать две колонки c названиями Year и Total.
Написать проверочный запрос, который вычисляет количество всех заказов.\
*/
GO

SELECT 
YEAR(OrderDate) AS [Year], 
COUNT(*) AS [Total] 
FROM dbo.Orders 
GROUP BY YEAR(OrderDate);

SELECT 
COUNT(*) AS [Orders count] 
FROM dbo.Orders;

/*
3.2.2. По таблице Orders найти количество заказов, оформленных каждым
продавцом.
Заказ для указанного продавца – это любая запись в таблице Orders, где в колонке
EmployeeID задано значение для данного продавца.
В результатах запроса надо высвечивать колонку с именем продавца (Должно
высвечиваться имя полученное конкатенацией LastName & FirstName. Эта строка
LastName & FirstName должна быть получена отдельным запросом в колонке
основного запроса. Также основной запрос должен использовать группировку
по EmployeeID.) с названием колонки ‘Seller’ и колонку c количеством заказов
высвечивать с названием 'Amount'.
Результаты запроса должны быть упорядочены по убыванию количества заказов.
*/
GO

SELECT 
	COUNT(*) AS Amount, 
	(SELECT 
		LastName + N' ' + FirstName 
		FROM dbo.Employees e 
		WHERE e.EmployeeID = o.EmployeeID) AS Seller
FROM dbo.Orders o
GROUP BY EmployeeID
ORDER BY Amount DESC;

/*
3.2.3 По таблице Orders найти количество заказов
Условия:
• Заказы сделаны каждым продавцом и для каждого покупателя;
• Заказы сделаны в 1998 году.
В результатах запроса надо высвечивать:
• Колонку с именем продавца (название колонки ‘Seller’);
• Колонку с именем покупателя (название колонки ‘Customer’);
• Колонку c количеством заказов высвечивать с названием 'Amount'.
В запросе необходимо использовать специальный оператор языка T-SQL для
работы с выражением GROUP (Этот же оператор поможет выводить строку “ALL”
в результатах запроса).
Группировки должны быть сделаны по ID продавца и покупателя.
Результаты запроса должны быть упорядочены по:
• Продавцу;
• Покупателю;
• убыванию количества продаж.

*/
GO

SELECT (
	CASE 
		WHEN GROUPING(o.EmployeeID) = 1 THEN N'ALL'
		ELSE (SELECT e.LastName + N' ' + e.FirstName AS Name 
			FROM dbo.Employees e 
			WHERE e.EmployeeID = o.EmployeeID)
	END
) AS Seller, 
(
	CASE 
		WHEN GROUPING(o.CustomerID) = 1 THEN 'ALL'
		ELSE (SELECT ContactName 
			FROM dbo.Customers c 
			WHERE c.CustomerID = o.CustomerID)
	END
) AS Customer, 
COUNT(*) AS Amount 
FROM dbo.Orders o
WHERE YEAR(o.OrderDate) = 1998
GROUP BY GROUPING SETS(CUBE(o.EmployeeID, o.CustomerID))
ORDER BY Seller ASC, Customer ASC, Amount DESC;

/*
3.2.4. Найти покупателей и продавцов, которые живут в одном городе.
Если в городе живут только продавцы или только покупатели, то информация о
таких покупателя и продавцах не должна попадать в результирующий набор.
В результатах запроса необходимо вывести следующие заголовки для результатов
запроса:
• ‘Person’;
• ‘Type’ (здесь надо выводить строку ‘Customer’ или ‘Seller’ в завимости от
типа записи);
• ‘City’.
Отсортировать результаты запроса по колонке ‘City’ и по ‘Person’.
*/
GO

SELECT * FROM (
		SELECT ContactName AS Person, City, 'Customer' AS [Type] 
		FROM dbo.Customers c
		UNION
		SELECT e.LastName + N' ' + e.FirstName AS Person, City, 'Seller' AS [Type] 
		FROM dbo.Employees e
	) AS Persons
WHERE City IN 
	(SELECT c.City 
	FROM dbo.Employees e
	JOIN dbo.Customers c ON c.City = e.City
	GROUP BY c.City)
ORDER BY City, Person;

/*
3.2.5. Найти всех покупателей, которые живут в одном городе.
В запросе использовать соединение таблицы Customers c собой -
самосоединение. Высветить колонки CustomerID и City.
Запрос не должен высвечивать дублируемые записи.
Для проверки написать запрос, который высвечивает города, которые
встречаются более одного раза в таблице Customers. Это позволит проверить
правильность запроса.
*/
GO

SELECT c.CustomerID AS CustomerID, c.City AS City 
FROM dbo.Customers c
JOIN dbo.Customers c1 ON c.City = c1.City
GROUP BY c.CustomerID, c.City
HAVING COUNT(c.CustomerID) > 1
ORDER BY City;

--здесь для проверки удобнее использовать города с кол-вом заказов там
SELECT COUNT(*) AS [Order count], City 
FROM dbo.Customers 
GROUP BY City 
HAVING COUNT(*) > 1 
ORDER BY City;

/*
3.2.6. По таблице Employees найти для каждого продавца его руководителя, т.е.
кому он делает репорты.
Высветить колонки с именами 'User Name' (LastName) и 'Boss'. В колонках должны
быть высвечены имена из колонки LastName.
Высвечены ли все продавцы в этом запросе?
*/
GO

SELECT e.LastName AS [User Name], e1.LastName AS [Boss] 
FROM dbo.Employees e
JOIN dbo.Employees e1 ON e.ReportsTo = e1.EmployeeID;

--в запросе высвечены не все продавцы, т.к. у кого то из продавцов нет руководителя