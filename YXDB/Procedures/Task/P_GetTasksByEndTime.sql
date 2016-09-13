Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTasksByEndTime')
BEGIN
	DROP  Procedure  P_GetTasksByEndTime
END

GO
/***********************************************************
过程名称： P_GetTasksByEndTime
功能描述： 获取任务列表根据交货时间
参数说明：	 
编写日期： 2016/6/1
程序作者： MU
调试记录： exec P_GetTasksByEndTime 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetTasksByEndTime]
	@StartEndTime nvarchar(100)='',
	@EndEndTime nvarchar(100)='',
	@UserID nvarchar(64)='',
	@OrderType int =-1,
	@FilterType int =-1,
	@FinishStatus int =-1,
	@PreFinishStatus int=-1,
	@TaskType int=-1,
	@ClientID nvarchar(64),
	@PageSize int=20,
	@PageIndex int=1,
	@TotalCount int output,
	@PageCount int output
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100),
	@condition nvarchar(1000)
	
	set @tableName='OrderTask t left join OrderTask t2 on t.OrderID=t2.OrderID and t2.Sort=t.Sort-1'
	set @columns='t.TaskID,t.OrderID,t2.TaskID PTaskID'
	set @key='t.TaskID'
	set @orderColumn='t.EndTime'
	set @condition=' t.status<>8  and t.ClientID='''+@ClientID+''''

	if(@UserID<>'')
		set @condition+=' and t.OwnerID='''+@UserID+''''

	if(@OrderType<>-1)
		set @condition+=' and t.OrderType='+str(@OrderType,2)

	if(@FinishStatus<>-1)
		set @condition+=' and t.FinishStatus='+str(@FinishStatus,2)
	else
		set @condition+=' and t.FinishStatus>0'

	if(@PreFinishStatus<>-1)
	begin
		if(@PreFinishStatus<>9)
			set @condition+=' and t2.FinishStatus='+ str(@PreFinishStatus)
		else
			set @condition+=' and t.Sort=1'
	end

	if(@TaskType<>-1)
	begin
		set @condition+=' and right(t.Mark,1)='+ str(@TaskType,2)
	end

	if(@StartEndTime<>'')
		set @condition+=' and t.EndTime>='''+@StartEndTime+''''

	if(@EndEndTime<>'')
		set @condition+=' and t.EndTime<'''+CONVERT(varchar(100), dateadd(day, 1, @EndEndTime), 23)+''''

	if(@FilterType<>-1)
	begin
		if(@FilterType=1)
			begin
				set @condition+=' and t.EndTime<GETDATE() and t.FinishStatus=1 '
			end
		else if(@FilterType=3 or @FilterType=2)
		begin
			set @condition+=' and t.EndTime>GETDATE() and t.FinishStatus=1 '

			if(@FilterType=2)
			begin
				set @condition+='and DateDiff(HH,GETDATE(),t.EndTime)*3< DateDiff(HH,t.AcceptTime,t.EndTime)'
			end
			else
			begin
				set @condition+='and DateDiff(HH,GETDATE(),t.EndTime)*3>= DateDiff(HH,t.AcceptTime,t.EndTime)'
			end
		end
		else if(@FilterType=4)
		begin
			set @condition+=' and t.FinishStatus=2 '
		end
	end

	declare @tmp table(AutoID int,TaskID nvarchar(64),OrderID nvarchar(64),PTaskID nvarchar(64))
	declare @total int,@page int

	insert into @tmp exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderColumn,@pageSize,@pageIndex,@total out,@page out,0 
	select @totalCount=@total,@pageCount =@page

	select  t.*,t2.FinishStatus as PreFinishStatus,t2.Title as PreTitle,t2.OwnerID POwnerID,t2.EndTime PEndTime,t2.CompleteTime PCompleteTime  from OrderTask t
	join @tmp tmp on t.TaskID=tmp.TaskID
	left join OrderTask t2 on t2.TaskID=tmp.PTaskID 

	select * from orders 
	where orderid in ( select OrderID from @tmp)


	


