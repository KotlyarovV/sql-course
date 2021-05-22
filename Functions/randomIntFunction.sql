use Datas
go
create function getRandomInteger (@from int, @to int, @rand float)
returns int
as
begin
	return FLOOR(@rand * (@to - @from + 1)) + @from
end