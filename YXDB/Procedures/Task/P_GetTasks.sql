Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTasks')
BEGIN
	DROP  Procedure  P_GetTasks
END

GO
/***********************************************************
过程名称： P_GetTasks
功能描述： 查询订单任务列表
参数说明：	 
编写日期： 2016/2/3
程序作者： MU
调试记录： declare @TotalCount int,@PageCount int  exec P_GetTasks @ClientID='c6c47173-337d-48eb-957c-1c22302ef113',@TotalCount=@TotalCount output,@PageCount=@PageCount output
************************************************************/
CREATE PROCEDURE [dbo].P_GetTasks
@KeyWords nvarchar(64)='',
@OwnerID nvarchar(64)='',
@IsParticipate int=0,
@Status int=-1,
@FinishStatus int=-1,
@OrderType int=-1,
@OrderProcessID nvarchar(64)='-1',
@OrderStageID nvarchar(64)='-1',
@ColorMark int=-1,
@TaskType int=-1,
@BeginDate nvarchar(100)='',
@EndDate nvarchar(100)='',
@TaskOrderColumn int=0,
@IsAsc int=0,
@ClientID nvarchar(64),
@PageSize int=20,
@PageIndex int=1,
@TotalCount int output,
@PageCount int output
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)
	
	set @tableName='OrderTask'
	set @columns='*'
	set @key='TaskID'
	set @orderColumn='createtime'
	set @condition=' 1=1 '

	if(@IsParticipate=1)
		set @condition +='and Members like ''%'+@OwnerID+'%'' '
	else
	begin
		if(@OwnerID<>'')
			set @condition+=' and OwnerID='''+@OwnerID+''''
	end

	if(@ClientID<>'')
		set @condition+=' and clientID='''+@ClientID+''''
		
	if(@KeyWords<>'')
		set @condition+=' and  ( Title like ''%'+@KeyWords+'%'''+' or OrderCode like ''%'+@KeyWords+'%'' or TaskCode like ''%'+@KeyWords+'%'')'
	
	if(@Status<>-1)
		set @condition+=' and Status='+ convert(nvarchar(2), @Status)

	if(@FinishStatus<>-1)
		set @condition+=' and FinishStatus='+ convert(nvarchar(2), @FinishStatus)

	if(@OrderProcessID<>'-1')
		set @condition+=' and ProcessID='''+ @OrderProcessID+''''

	if(@OrderStageID<>'-1')
		set @condition+=' and StageID='''+ @OrderStageID+''''

	if(@OrderType<>-1)
		set @condition+=' and OrderType='+ convert(nvarchar(2), @OrderType)

	if(@ColorMark<>-1)
		set @condition+=' and ColorMark='+ convert(nvarchar(2), @ColorMark)

	if(@TaskType<>-1)
		set @condition+=' and Mark='+ convert(nvarchar(2), @TaskType)

	if(@BeginDate<>'')
		set @condition+=' and createtime>='''+@BeginDate+''''

	if(@EndDate<>'')
		set @condition+=' and createtime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndDate), 23)+''''


	if(@TaskOrderColumn<>0)
	begin
		if(@TaskOrderColumn=1)
			set @orderColumn='EndTime'
	end

	if(@IsAsc=0)
		set @orderColumn+=' desc '
	else
		set @orderColumn+=' asc '

	set @orderColumn+=',sort asc'

	declare @total int,@page int

	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@PageIndex,@total out,@page out,0

	set @TotalCount=@total
	set @PageCount =@page





