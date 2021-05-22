use Datas

go
create procedure createTables
as
begin
	create table Persons (
		id uniqueidentifier primary key,
		lastName varchar(100),
		firstName varchar(100)
	)

	create table Houses (
		id uniqueidentifier primary key,
		address varchar(500),
		price decimal
	)

	create table HouseOwners (
		owner_id uniqueidentifier foreign key references Persons,
		house_id uniqueidentifier foreign key references Houses,
		primary key(owner_id, house_id)
	)
end

go
use Datas
go
create procedure deleteTables
as
begin
	drop table HouseOwners
	drop table Houses
	drop table Persons
end