alter proc etl.InitialSetup as

select 1


/* schema setup

create schema stg
create schema etl
create schema ods
*/


/* all sql access to local files

-- To allow advanced options to be changed.  
EXECUTE sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXECUTE sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  
*/


/* landing spot for pga files

CREATE TABLE [stg].[Files] 
(
[Contents] varchar(4000)
,[FilePath] varchar(400)
,[FileName] varchar(400)
,[UploadDateTime] DATETIME
)

CREATE VIEW [stg].[vw_Files] as
SELECT [Contents]
FROM [stg].[Files] 
*/




/*  create list of folders for simplicity in ImportTXTFiles script

DECLARE @filepath nvarchar(100) = 'C:\Users\chweb\Coursework\stats_txt\'
DECLARE @query varchar(1000)
DECLARE @files TABLE (Name varchar(200) NULL)


SET @query = 'master.dbo.xp_cmdshell ''dir "' + @filepath +  '" /b'''
INSERT @files (name) 
EXEC (@query)

SELECT name as FilePath 
into [stg].[FileFolders]
from @files
*/

