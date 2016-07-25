Use IntFactory
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
@BeginEndDate nvarchar(100)='',
@EndEndDate nvarchar(100)='',
@TaskOrderColumn int=0,
@IsAsc int=0,
@ClientID nvarchar(64),
@InvoiceStatus int=-1,
@PreFinishStatus int=-1,
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
	
	set @tableName='OrderTask t left join OrderTask t2 on t.OrderID=t2.OrderID and t2.Sort=t.Sort-1'
	set @columns='t.*,t2.FinishStatus as PreFinishStatus'
	set @key='t.TaskID'
	set @orderColumn='t.createtime'
	set @condition=' 1=1 '

	if(@IsParticipate=1)
	begin
		set @condition+=' and t.TaskID in( select distinct TaskID from TaskMember where Status<>9 and MemberID='''+@OwnerID+''' )'
	end
	else
	begin
		if(@OwnerID<>'')
			set @condition +='and t.OwnerID='''+@OwnerID+''' '
	end

	if(@ClientID<>'')
		set @condition+=' and t.clientID='''+@ClientID+''''
		
	if(@KeyWords<>'')
		set @condition+=' and  ( t.Title like ''%'+@KeyWords+'%'''+' or t.OrderCode like ''%'+@KeyWords+'%'' or t.TaskCode like ''%'+@KeyWords+'%'')'
	
	if(@Status<>-1)
		set @condition+=' and t.Status='+ convert(nvarchar(2), @Status)

	if(@FinishStatus<>-1)
		set @condition+=' and t.FinishStatus='+ convert(nvarchar(2), @FinishStatus)

	if(@PreFinishStatus<>-1)
		set @condition+=' and t2.FinishStatus='+ convert(nvarchar(2), @PreFinishStatus)

	if(@OrderProcessID<>'-1')
		set @condition+=' and t.ProcessID='''+ @OrderProcessID+''''

	if(@OrderStageID<>'-1')
		set @condition+=' and t.StageID='''+ @OrderStageID+''''

	if(@OrderType<>-1)
		set @condition+=' and t.OrderType='+ convert(nvarchar(2), @OrderType)

	if(@ColorMark<>-1)
		set @condition+=' and t.ColorMark='+ convert(nvarchar(2), @ColorMark)

	if(@TaskType<>-1)
	begin
		set @condition+=' and right(t.Mark,1)='+ convert(nvarchar(2), @TaskType)
	end

	if(@BeginDate<>'')
		set @condition+=' and t.createtime>='''+@BeginDate+''''

	if(@EndDate<>'')
		set @condition+=' and t.createtime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndDate), 23)+''''

	if(@BeginEndDate<>'')
		set @condition+=' and t.endtime>='''+@BeginEndDate+''''

	if(@EndEndDate<>'')
		set @condition+=' and t.endtime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndEndDate), 23)+''''

	if(@InvoiceStatus=2)
	begin
		set @condition +=' and t.FinishStatus = 1 and t.EndTime< GetDate() '
	end
	else if(@InvoiceStatus=1)
	begin
		set @condition +=' and t.FinishStatus = 1 and t.EndTime > GetDate() and datediff(hour,t.accepttime,t.EndTime) > datediff(hour,GetDate(),t.EndTime)*3 '
	end
	else if(@InvoiceStatus=0)
	begin
		set @condition +=' and t.FinishStatus = 1 and t.EndTime > GetDate() and datediff(hour,t.accepttime,t.EndTime) <= datediff(hour,GetDate(),t.EndTime)*3 '
	end

	if(@TaskOrderColumn<>0)
	begin
		if(@TaskOrderColumn=1)
			set @orderColumn='t.EndTime'
	end

	if(@IsAsc=0)
		set @orderColumn+=' desc '
	else
		set @orderColumn+=' asc '

	set @orderColumn+=',t.sort asc'

	declare @orderby nvarchar(20)
	if(@isAsc=0)
	begin
		set @orderby='desc'
	end
	else
	begin
		set @orderby='asc'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderColumn,@pageSize,@pageIndex,@total out,@page out,0 
	select @totalCount=@total,@pageCount =@page





