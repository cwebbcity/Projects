USE [MLB]
GO
/****** Object:  StoredProcedure [etl].[Importstatcast]    Script Date: 11/17/2020 3:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [etl].[Importstatcast] as
 
declare @filepath nvarchar(100)
declare @filefolder nvarchar(100)
declare @filename nvarchar(100)
declare @files table (Name varchar(200) NULL)
declare @query nvarchar(max)
declare @numfiles INT
declare @viewname nvarchar(100)


set @filefolder = 'statcast'
set @filepath = 'C:\Users\chweb\Coursework\MLB\'
set @viewname = 'stg.statcast'


DECLARE curs_files CURSOR FOR
SELECT Name FROM @files WHERE Name IS NOT NULL

DELETE FROM @files

--Pull a list of the TXT file names from the folder that they're stored in
SET @query = 'master.dbo.xp_cmdshell ''dir "' + @filepath + @filefolder + '" /b'''
INSERT @files(Name) 
EXEC (@query)

  
--For each CSV file, execute a query
SET @numfiles =0
OPEN curs_files
FETCH NEXT FROM curs_files INTO @filename
WHILE (@@FETCH_STATUS = 0)
BEGIN
    SET @numfiles+=1
  
    --BULK INSERT each TXT file into the view and update the table with folder, file, and datetime 
    SET @query = ('BULK INSERT ' + @ViewName
    + ' FROM ''' + @Filepath + @filefolder + '\' + @filename + ''' WITH(
				DATAFILETYPE = ''char''
      , FIRSTROW = 1
      , FIELDTERMINATOR = ''|''
      , ROWTERMINATOR = ''0x0a'');'
			)
  
  
    PRINT 'Importing ' + @filename + ' from ' + @filefolder + ' into ' + @ViewName
    EXEC (@query)
  
    FETCH NEXT FROM curs_files INTO @filename
END
  
	

CLOSE curs_files
DEALLOCATE curs_files
  