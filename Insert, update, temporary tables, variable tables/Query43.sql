/*
Запрос 2. Выбрать все книги у которых дата регистрации в библиотеке
больше 01.02.2005, либо не задана вообще.Запрос 2 выполнить в третьем соединении к БД.
Скрипт запроса записать в файл Query43.sql.*/SELECT b.Name FROM ##tblBook b
LEFT JOIN ##tblBookInLibrary bil 
ON b.BookID = bil.BookID
WHERE bil.Date is NULL or bil.Date > '2005-02-01';

GO