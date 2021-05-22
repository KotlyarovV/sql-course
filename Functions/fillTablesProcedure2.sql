use Datas

go 
create or alter procedure clearDatabase
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

create or alter procedure fillTables
	@personsCount int,
	@housesCount int
as
begin
	while (@personsCount > 0)
	begin
		insert into Persons values (newid(), convert(varchar(100), newid()), convert(varchar(100), newid()))
		set @personsCount = @personsCount - 1
	end

	while (@housesCount > 0)
	begin
		declare @housePrice int
		select @housePrice = dbo.getRandomInteger(300, 600, rand())
		insert into Houses values (newid(), convert(varchar(500), newid()), cast(@housePrice as decimal(18,0)))
		set @housesCount = @housesCount - 1
	end

	declare @personId uniqueidentifier
	declare @person_fetch_status int
	declare person_cursor cursor 
		for select id from Persons
	open person_cursor
	fetch next from person_cursor into @personId
	set @person_fetch_status = @@FETCH_STATUS
	select @personId
	
	declare @houseId uniqueidentifier
	declare @house_fetch_status int
	declare house_cursor cursor 
		for select id from Houses
	open house_cursor
	fetch next from house_cursor into @houseId
	set @house_fetch_status = @@FETCH_STATUS
	
	while @house_fetch_status = 0 and @person_fetch_status = 0
	begin
		insert into HouseOwners values (@personId, @houseId)
		
		fetch next from person_cursor into @personId
		set @person_fetch_status = @@FETCH_STATUS

		fetch next from house_cursor into @houseId
		set @house_fetch_status = @@FETCH_STATUS

	end
	close person_cursor  
    deallocate person_cursor
	close house_cursor
	deallocate house_cursor
end