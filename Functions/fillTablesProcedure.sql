use Datas

go 
create procedure clearDatabase
as
begin
	declare @table_name varchar(100)
	declare tables_cursor cursor 
		for select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE'
	open tables_cursor
	fetch next from tables_cursor into @table_name
	while @@FETCH_STATUS = 0
	begin
		exec('ALTER TABLE ' + @table_name + ' NOCHECK CONSTRAINT ALL')
		exec('delete from ' + @table_name)
		exec('ALTER TABLE ' + @table_name + ' CHECK CONSTRAINT ALL')
		fetch next from tables_cursor into @table_name
	end
	close tables_cursor
	deallocate tables_cursor
end


go
create procedure fillTables
	@personsCount int,
	@housesCount int
as
begin
	while (@personsCount > 0)
	begin
		insert into Persons values (newid(), convert(varchar(100), newid()), convert(varchar(100), newid()))
		set @personsCount = @personsCount - 1
	end

	declare @personId uniqueidentifier
	declare person_cursor cursor 
		for select top (@housesCount) id from Persons
	declare @housePrice int
	open person_cursor
	fetch next from person_cursor into @personId

	while @@FETCH_STATUS = 0
	begin
		select @housePrice = dbo.getRandomInteger(300, 600, rand())
		insert into Houses values (newid(), convert(varchar(500), newid()), @personId,	cast(@housePrice as decimal(18,0)))
		fetch next from person_cursor into @personId
	end
	close person_cursor  
    deallocate person_cursor
end