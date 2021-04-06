use Northwind

/*
� �������� ������ ���������� � ������� Orders ���� OrderNum.
��� ���� bigint.
������ ������ ������ ����� ��������� ��������� ���.
� �������� �������� ���������, ������ ����������� ������ �
������ ������ ������� � 1 � ������� ��� ������ � ����
OrderNum. ���������� ������ ������ ��� ���������� ��������.
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE table_name = 'Orders'
    AND column_name = 'OrderNum')
BEGIN
    ALTER TABLE dbo.Orders
	ADD OrderNum BIGINT
END
	UPDATE 
		SET o.OrderNum = o1.ONum;
� �������� ������ ���������� � ������� Orders ����
GroupMonthNum. ��� ���� bigint.
������ ������ ������ ����� ��������� ��������� ���.
� �������� ������� ���������, ������ ����������� ������ ��
�������. ������ ������ ��������� ������ ������� � 1.
���������� ������ ������� � ���� GroupMonthNum. ��� ����
������� ����� ������ ��� �������� ������ ���� ���������.
���������� ������ ������ ��� ���������� ��������.
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

CREATE OR ALTER PROCEDURE FillGroupMonthNum
	UPDATE 
		SET o.GroupMonthNum = o1.ONum;
����������� �� ��������. ���������� ������� ������ ����������
������� ���������� @PageCount. ��������� ������ �������
��������� �������:
� OrderID
� OrderNum
� OrderDate
� RowCount � ���������� ����� � Order Details �� ������
� PageNumber.