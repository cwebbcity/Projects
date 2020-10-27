

EXEC [etl].[ImportTXTFiles]
    @filepath = 'C:\Users\chweb\Coursework\stats_txt\'
		,@ViewName = '[stg].[vw_Files]'
    ,@StgName = '[stg].[Files]'
    ,@ResetTable = 1

