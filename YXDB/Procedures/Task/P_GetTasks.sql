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
	set @columns='TaskID'
	set @key='TaskID'
	set @orderColumn='createtime'
	set @condition=' 1=1 '

	if(@IsParticipate=1)
	begin
		set @condition+=' and TaskID in( select distinct TaskID from TaskMember where Status<>9 and MemberID='''+@OwnerID+''' )'
	end
	else
	begin
		if(@OwnerID<>'')
			set @condition +='and OwnerID='''+@OwnerID+''' '
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
	begin
		set @condition+=' and right(Mark,1)='+ convert(nvarchar(2), @TaskType)
	end

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
	declare @orderby nvarchar(20)
	if(@isAsc=0)
	begin
		set @orderby='desc'
	end
	else
	begin
		set @orderby='asc'
	end
	declare @CommandSQL nvarchar(4000)
	set @CommandSQL= 'select @total=count(0) from '+@tableName+' where '+@condition
	exec sp_executesql @CommandSQL,N'@total int output',@total output
	set @page=CEILING(@total * 1.0/@pageSize)

	if(@PageIndex=0 or @PageIndex=1)
	begin 
		if @orderColumn!=''
		begin
			set	@orderColumn=@orderColumn+','
		end
		set @CommandSQL='select TaskID into #tmp from (select top '+str(@pageSize)+' '+@columns+' from '+@tableName+' where '+@condition+' order by '+@orderColumn+@key+' '+@orderby+' ) as tids'
	end
	else
	begin
		if(@PageIndex>@total)
		begin
			set @PageIndex=@total
		end
		if @orderColumn!=''
		begin
			set	@orderColumn=@orderColumn+','
		end
		set @CommandSQL='select TaskID into #tmp from ( select * from (select row_number() over( order by '+@orderColumn+@key+' '+@orderby+') as rowid , '+@columns+' from '+@tableName+' where '+@condition+'  ) as dt where rowid between '+str((@PageIndex-1) * @pageSize + 1)+' and '+str(@PageIndex* @pageSize)+'	) as tids'
	end

		set @CommandSQL=@CommandSQL+'	select t1.*,t2.FinishStatus as PreFinishStatus from OrderTask t1 left join OrderTask t2 on t1.OrderID=t2.OrderID and t2.Sort=t1.Sort-1
where t1.TaskID in (select * from #tmp)   drop table #tmp'

	exec (@CommandSQL)

	set @TotalCount=@total
	set @PageCount =@page





