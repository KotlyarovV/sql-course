/*
4.2.2. ���������� ���������� ������� 4.2.1 ����� �������, �����
�������� ��������� ������ ����������� � ����� ���������� � ��.
������ ������� �������� � ���� Query41.sql;*/

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
(N'����� � ���'), (N'������������ � ���������'), (N'������ � ���������'), (N'����� ���');

INSERT INTO ##tblBookInLibrary 
VALUES
(1, '2006-05-01'),
(3, '2004-07-05');

GO