use Northwind

GO

--SELECT QUOTENAME('NAME'), '[' + 'NAME' + ']' одно и то же

CREATE OR ALTER PROCEDURE dbo.GetAllTables
AS
BEGIN
	WITH cte AS (SELECT 
		o.type_desc AS ObjectType, 
		o.name AS ObjectName, 
		o1.name AS ParentObjectName, 
		SCHEMA_NAME(o.schema_id) AS SchemaName,
		CASE 
			WHEN o.type IN ('P','FN', 'V', 'TR') THEN OBJECT_DEFINITION(o.object_id)
			WHEN o.type = 'U'
				THEN ('CREATE TABLE ' + SCHEMA_NAME(o.schema_id) + '[' + o.name + '] (' + (
							select STRING_AGG(concat(
									'[' + COLUMN_NAME + ']', 
									' ',
									DATA_TYPE,
									(CASE
										WHEN t.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN
											CASE
												WHEN t.CHARACTER_MAXIMUM_LENGTH = - 1 
													THEN '(max)'
												WHEN t.CHARACTER_MAXIMUM_LENGTH <> -1 
													THEN '(' + CONVERT(VARCHAR(100), t.CHARACTER_MAXIMUM_LENGTH) + ')'
											END
										WHEN t.DATA_TYPE = 'DECIMAL' THEN '(' + CONVERT(VARCHAR(100), t.NUMERIC_PRECISION) 
											+ ',' + CONVERT(VARCHAR(100), t.NUMERIC_SCALE) + ')'
										ELSE ''
										END),
									' ',
									CASE 
										WHEN IS_NULLABLE = 'YES' THEN 'null'
										WHEN IS_NULLABLE = 'NO' THEN 'not null'
									END), ', ' + CHAR(13))
							FROM information_schema.columns t
							WHERE TABLE_SCHEMA = SCHEMA_NAME(o.schema_id) AND TABLE_NAME = o.name) + ')')
			WHEN o.type = 'F' THEN (
					SELECT  
						'ALTER TABLE ' 
						+ SCHEMA_NAME(tab1.schema_id) + '.[' + tab1.name + '] ADD CONSTRAINT ' + obj.name + ' FOREIGN KEY ('
						+	(
								SELECT 
									STRING_AGG(c.name, ', ') 
								FROM sys.columns c 
									JOIN sys.foreign_key_columns fkc 
									ON c.object_id = tab1.object_id AND c.column_id = parent_column_id
									WHERE 
										fkc.constraint_object_id = fk.object_id)
						+ ') REFERENCES ' + SCHEMA_NAME(tab2.schema_id) + '.[' + tab2.name + ']('+
						+	(
								SELECT 
									STRING_AGG(c.name, ', ') 
								FROM sys.columns c 
									JOIN sys.foreign_key_columns fkc 
									ON c.object_id = tab2.object_id AND c.column_id = referenced_column_id
									WHERE fkc.constraint_object_id = fk.object_id)
						+ ')'
						+ (CASE 
								WHEN fk.update_referential_action = 0 THEN 'ON UPDATE NO ACTION'
								WHEN fk.update_referential_action = 1 THEN 'ON UPDATE CASCADE'
								WHEN fk.update_referential_action = 2 THEN 'ON UPDATE SET NULL'
								WHEN fk.update_referential_action = 3 THEN 'ON UPDATE SET DEFAULT'
							END)
						+ + (CASE 
								WHEN fk.delete_referential_action = 0 THEN 'ON DELETE NO ACTION'
								WHEN fk.delete_referential_action = 1 THEN 'ON DELETE CASCADE'
								WHEN fk.delete_referential_action = 2 THEN 'ON DELETE SET NULL'
								WHEN fk.delete_referential_action = 3 THEN 'ON DELETE SET DEFAULT'
							END)
					FROM sys.foreign_keys fk
					JOIN sys.objects obj
						ON obj.object_id = fk.object_id
					JOIN sys.tables tab1
						ON tab1.object_id = fk.parent_object_id
					JOIN sys.tables tab2
						ON tab2.object_id = fk.referenced_object_id
					WHERE obj.object_id = o.object_id)
			ELSE ''
			END AS Script
	FROM sys.objects o
	LEFT JOIN sys.objects o1 ON o.parent_object_id = o1.object_id
	WHERE o.type IN ('F','FN','P', 'V', 'U', 'TR')
	UNION ALL
	SELECT 
		CASE
			WHEN i.is_primary_key = 1 THEN 'PRIMARY KEY'
			WHEN i.type = 1 THEN 'CLUSTERED INDEX'
			WHEN i.type = 2 THEN 'NONCLUSTERED INDEX'
		END AS ObjectType,
		i.name AS ObjectName,
		t.name AS ParentObjectName,
		SCHEMA_NAME(t.schema_id) AS SchemaName,
		CASE 
			WHEN i.is_primary_key = 1
				THEN ('ALTER TABLE ' + SCHEMA_NAME(t.schema_id) + '.[' + t.name + '] ADD CONSTRAINT '
				+ i.name + '  PRIMARY KEY (' + 
					STUFF((
						SELECT ', ' + c.name  
						FROM sys.index_columns ic
							JOIN sys.columns c ON ic.object_id = c.object_id AND c.column_id = ic.column_id
						WHERE i.object_id = ic.object_id AND i.index_id = ic.index_id AND ic.is_included_column = 0
						GROUP BY c.name, key_ordinal
						ORDER BY key_ordinal FOR XML PATH('')), 1, 2, '') 
				+ ')' + IIF(i.fill_factor = 0, '', ' WITH (FILLFACTOR = ' + CONVERT(VARCHAR(MAX), i.fill_factor) 
				+ ')')
				)
			WHEN i.is_primary_key = 0
				THEN ('CREATE ' + i.type_desc COLLATE DATABASE_DEFAULT + ' INDEX ' + i.name + ' ON ' 
				+ SCHEMA_NAME(t.schema_id) + '.[' + t.name + ']('
				+ STUFF((
					SELECT ', ' + c.name  
					FROM sys.index_columns ic
						JOIN sys.columns c ON ic.object_id = c.object_id AND c.column_id = ic.column_id
					WHERE i.object_id = ic.object_id AND i.index_id = ic.index_id and ic.is_included_column = 0
					GROUP BY c.name, key_ordinal
					ORDER BY key_ordinal FOR XML PATH('')), 1, 2, '') 
				+ ')'
			
				+ COALESCE(STUFF((
					SELECT ', ' + c.name  FROM sys.index_columns ic
						JOIN sys.columns c ON ic.object_id = c.object_id AND c.column_id = ic.column_id
					WHERE i.object_id = ic.object_id AND i.index_id = ic.index_id AND ic.is_included_column = 1
					GROUP BY c.name, key_ordinal
					ORDER BY key_ordinal FOR XML PATH('')), 1, 2, ' INCLUDE(') + ')', '')
				+ IIF(i.fill_factor = 0, '', ' WITH (FILLFACTOR = ' + CONVERT(VARCHAR(MAX), i.fill_factor) + ')')
				)
			END AS Script
	FROM sys.indexes i
		JOIN sys.tables t ON  t.object_id = i.object_id
		WHERE i.name IS NOT NULL)

	SELECT *, HASHBYTES('SHA2_256', Script) 
	FROM cte
END

GO

CREATE OR ALTER PROCEDURE dbo.CollectStatistics
AS
BEGIN

	IF OBJECT_ID('dbo.[ExecStatistics]') IS NULL
	CREATE TABLE dbo.ExecStatistics (
		ProcedureName varchar(1000),
		CacheAddingDate Datetime,
		DateOfLastExecuting Datetime,
		ExecutionPlan nvarchar(max),
		NumberOfExecutions int,
		TotalPhysicalReads bigint,
		MinPhysicalReads bigint,
		MaxPhysicalReads bigint,
		TotalElapsedTime bigint,
		MinElapsedTime bigint,
		MaxElapsedTime bigint,
		TotalWorkerTime bigint,
		MinWorkerTime bigint,
		MaxWorkerTime bigint,
		CONSTRAINT PK_ProcedureName_CacheAddingDate PRIMARY KEY (ProcedureName, CacheAddingDate)
	)

	MERGE dbo.[ExecStatistics] as target
	USING (
			SELECT
				SCHEMA_NAME(o.schema_id) + '.[' + o.name + ']' AS ProcedureName,
				s.cached_time AS CacheAddingDate,
				s.last_execution_time AS DateOfLastExecuting,
				query_plan AS ExecutionPlan,
				s.execution_count AS NumberOfExecutions,
				s.total_physical_reads AS TotalPhysicalReads,
				s.min_physical_reads AS MinPhysicalReads,
				s.max_physical_reads AS MaxPhysicalReads,
				s.total_elapsed_time AS TotalElapsedTime,
				s.min_elapsed_time AS MinElapsedTime,
				s.max_elapsed_time AS MaxElapsedTime,
				s.total_worker_time AS TotalWorkerTime,
				s.min_worker_time AS MinWorkerTime,
				s.max_worker_time AS MaxWorkerTime
			FROM sys.dm_exec_procedure_stats s
			JOIN sys.objects o on o.object_id = s.object_id
			OUTER APPLY sys.dm_exec_text_query_plan(s.plan_handle, 0, -1)
		) as source
	on target.ProcedureName = source.ProcedureName and target.CacheAddingDate = source.CacheAddingDate
	WHEN MATCHED THEN UPDATE 
		SET target.DateOfLastExecuting = source.DateOfLastExecuting,
			target.ExecutionPlan = source.ExecutionPlan,
			target.NumberOfExecutions = source.NumberOfExecutions,
			target.TotalPhysicalReads = source.TotalPhysicalReads,
			target.MinPhysicalReads = source.MinPhysicalReads,
			target.MaxPhysicalReads = source.MaxPhysicalReads,
			target.TotalElapsedTime = source.TotalElapsedTime,
			target.MinElapsedTime = source.MinElapsedTime,
			target.MaxElapsedTime = source.MaxElapsedTime,
			target.TotalWorkerTime = source.TotalWorkerTime,
			target.MinWorkerTime = source.MinWorkerTime,
			target.MaxWorkerTime = source.MaxWorkerTime
	WHEN NOT MATCHED THEN INSERT VALUES
		(
			source.ProcedureName,
			source.CacheAddingDate,
			source.DateOfLastExecuting,
			source.ExecutionPlan,
			source.NumberOfExecutions,
			source.TotalPhysicalReads,
			source.MinPhysicalReads,
			source.MaxPhysicalReads,
			source.TotalElapsedTime,
			source.MinElapsedTime,
			source.MaxElapsedTime,
			source.TotalWorkerTime,
			source.MinWorkerTime,
			source.MaxWorkerTime);
END

