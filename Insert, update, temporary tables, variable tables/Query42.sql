/*
������ 1. ������� ��� �����, � ���� ���� ������ ���� ��������� ������ �
��� ����,
� ������� ���� ����������� ������ 01.02.2005

������ 1 ��������� � ������ ���������� � ��.
������ ������� �������� � ���� Query42.sql;
*/

SELECT b.Name, bil.Date FROM ##tblBook b
LEFT JOIN ##tblBookInLibrary bil 
ON b.BookID = bil.BookID;

GO