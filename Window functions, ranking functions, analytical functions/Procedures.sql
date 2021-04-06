use Northwind

/*7.3.3.
Х Ќапишите скрипт добавлени€ в таблицу Orders пол€ OrderNum.
“ип пол€ bigint.
ѕричем данный скрипт можно выполн€ть несколько раз.
Х Ќапишите хранимую процедуру, котра€ пронумерует заказы в
каждом мес€це начина€ с 1 и запишет эти номера в поле
OrderNum. ќдинаковые мес€ца разных лет нумеруютс€ отдельно.*/IF NOT EXISTS(SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE table_name = 'Orders'
    AND column_name = 'OrderNum')
BEGIN
    ALTER TABLE dbo.Orders
	ADD OrderNum BIGINT
ENDGOCREATE OR ALTER PROCEDURE FillOrderNumASBEGIN	;WITH ONumbers	AS (		SELECT 			o.OrderID, 			ROW_NUMBER() over(				PARTITION BY 					YEAR(o.OrderDate), MONTH(o.OrderDate) 				ORDER BY o.OrderDate) AS ONum		FROM Orders o)	MERGE Orders AS o		USING ONumbers AS o1		ON o.OrderID = o1.OrderID	WHEN MATCHED THEN
	UPDATE 
		SET o.OrderNum = o1.ONum;END/*7.3.4.
Х Ќапишите скрипт добавлени€ в таблицу Orders пол€
GroupMonthNum. “ип пол€ bigint.
ѕричем данный скрипт можно выполн€ть несколько раз.
Х Ќапишите храниму процедуру, котра€ сгруппирует заказы по
мес€цам.  аждой группе проставит номера начина€ с 1.
ѕолученные номера запишет в поле GroupMonthNum. ƒл€ всех
заказов одной группы эти значени€ должны быть одинаковы.
ќдинаковые мес€ца разных лет нумеруютс€ отдельно.
*/

IF NOT EXISTS(SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE table_name = 'Orders'
    AND column_name = 'GroupMonthNum')
BEGIN
    ALTER TABLE dbo.Orders
	ADD GroupMonthNum BIGINT
END

GO

CREATE OR ALTER PROCEDURE FillGroupMonthNumASBEGIN	;WITH ONumbers	AS (		SELECT 			o.OrderID, 			  DENSE_RANK() over(				ORDER BY YEAR(o.OrderDate), MONTH(o.OrderDate)) AS ONum		FROM Orders o)	MERGE Orders AS o		USING ONumbers AS o1		ON o.OrderID = o1.OrderID	WHEN MATCHED THEN
	UPDATE 
		SET o.GroupMonthNum = o1.ONum;END/*7.3.5. Ќапишите хранимую процедуру, котора€ все заказы равномерно
разделенные на страницы.  оличество страниц должно задаватьс€
входным параметром @PageCount. ѕроцедура должна вернуть
следующие колонки:
Х OrderID
Х OrderNum
Х OrderDate
Х RowCount Ц количество строк в Order Details по заказу
Х PageNumber.*/GOCREATE OR ALTER PROCEDURE ShowPages	@PageCount INTASBEGIN	;WITH CTE_OrderNumbers	AS (		SELECT			od.OrderID, COUNT(od.OrderID) as RowsCount		FROM [Order Details] od 		GROUP BY od.OrderID	)	SELECT 		o.OrderID, o.OrderNum, o.OrderDate, 		COALESCE(ons.RowsCount, 0) as [RowCount],		ntile(@PageCount) OVER(ORDER BY o.OrderID) as PageNumber 	FROM Orders o	LEFT JOIN CTE_OrderNumbers ons on ons.OrderID = o.OrderIDEND