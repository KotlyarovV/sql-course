/*
������ 2. ������� ��� ����� � ������� ���� ����������� � ����������
������ 01.02.2005, ���� �� ������ ������.������ 2 ��������� � ������� ���������� � ��.
������ ������� �������� � ���� Query43.sql.*/SELECT b.Name FROM ##tblBook b
LEFT JOIN ##tblBookInLibrary bil 
ON b.BookID = bil.BookID
WHERE bil.Date is NULL or bil.Date > '2005-02-01';

GO