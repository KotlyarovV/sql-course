/*
4.2.2. Переделать выполнение задания 4.2.1 таким образом, чтобы
создание временных таблиц выполнялось в одном соединении к БД.
Скрипт запроса записать в файл Query41.sql;*/

IF OBJECT_ID('TEMPDB..##tblBook') IS NOT NULL DROP TABLE ##tblBook
	CREATE TABLE ##tblBook (
		BookID INT PRIMARY KEY IDENTITY(1, 1),
		Name varchar(100)
);

IF OBJECT_ID('TEMPDB..##tblBookInLibrary') IS NOT NULL DROP TABLE ##tblBookInLibrary
	CREATE TABLE ##tblBookInLibrary (
		BookID INT,
		Date DATE
);

INSERT INTO ##tblBook (Name)
VALUES 
(N'Война и мир'), (N'Преступление и наказание'), (N'Мастер и маргарита'), (N'Тихий дон');

INSERT INTO ##tblBookInLibrary 
VALUES
(1, '2006-05-01'),
(3, '2004-07-05');

GO