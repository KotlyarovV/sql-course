/*
Запрос 1. Выбрать все книги, а поле дата должно быть заполнено только у
тех книг,
у которых дата регистрации больше 01.02.2005

Запрос 1 выполнить в другом соединении к БД.
Скрипт запроса записать в файл Query42.sql;
*/

SELECT b.Name, bil.Date FROM ##tblBook b
LEFT JOIN ##tblBookInLibrary bil 
ON b.BookID = bil.BookID;

GO