/*
������ 2. ������� ��� ����� � ������� ���� ����������� � ����������
������ 01.02.2005, ���� �� ������ ������.
������ ������� �������� � ���� Query43.sql.
LEFT JOIN ##tblBookInLibrary bil 
ON b.BookID = bil.BookID
WHERE bil.Date is NULL or bil.Date > '2005-02-01';

GO