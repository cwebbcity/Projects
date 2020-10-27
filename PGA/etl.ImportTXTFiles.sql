USE [PGA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [etl].[ImportTXTFiles]
    @Filepath varchar(500)
		--,@filefolder varchar(500)
		,@ViewName varchar(128)
    ,@StgName varchar(128)
    ,@ResetTable bit = 0 
AS
  
SET QUOTED_IDENTIFIER OFF
  
DECLARE @query varchar(1000)
DECLARE @numfiles int
DECLARE @numfolders int
DECLARE @filename varchar(100)
DECLARE @filefolder varchar(100)
DECLARE @files TABLE (Name varchar(200) NULL)
 
 
--Delete the contents of the staging table
IF @ResetTable = 1
BEGIN
    PRINT 'Emptying table ' + @StgName + '...'
    EXEC ('DELETE ' + @StgName)
END

--Pull a list of the folders data is stored in (probably should make this dynamic)
DECLARE  curs_folders CURSOR FOR
SELECT filepath from [stg].[FileFolders] WHERE filepath is not NULL
SET @numfolders = 0
OPEN curs_folders
FETCH NEXT FROM curs_folders INTO @filefolder
WHILE (@@FETCH_STATUS = 0)
BEGIN
		SET @numfolders+=1

  

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
      , FIELDTERMINATOR = '',''
      , ROWTERMINATOR = ''0x0a'');'

  
    + ' UPDATE ' + @StgName
    + ' SET [FilePath] = ' + '''' + @filefolder + ''''
    + ' WHERE [FilePath] Is Null;'
		
		+ ' UPDATE ' + @StgName
    + ' SET [FileName] = ' + '''' + @filename + ''''
    + ' WHERE [FileName] Is Null;'
  
    + ' UPDATE ' + @StgName
    + ' SET [UploadDatetime] = ' + '''' + CAST(GETDATE() as nvarchar(1000)) + ''''
    + ' WHERE [UploadDatetime] Is Null;'
    )
  
    PRINT 'Importing ' + @filename + ' from ' + @filefolder + ' into ' + @ViewName
    EXEC (@query)
  
    FETCH NEXT FROM curs_files INTO @filename
END
  
	

CLOSE curs_files
DEALLOCATE curs_files

		FETCH NEXT FROM curs_folders INTO @filefolder

END
CLOSE curs_folders
DEALLOCATE curs_folders