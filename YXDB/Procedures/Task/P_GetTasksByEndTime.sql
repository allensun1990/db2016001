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
	
	set @tableName='OrderTask'
	set @columns='*'
	set @key='TaskID'
	set @orderColumn='EndTime'
	set @condition=' status<>8 and FinishStatus=1 and ClientID='''+@ClientID+''''

	if(@UserID<>'')
		set @condition+=' and OwnerID='''+@UserID+''''

	if(@OrderType<>-1)
		set @condition+=' and OrderType='+convert(nvarchar(2), @OrderType)

	if(@StartEndTime<>'')
		set @condition+=' and EndTime>='''+@StartEndTime+''''

	if(@EndEndTime<>'')
		set @condition+=' and EndTime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndEndTime), 23)+''''

	if(@FilterType<>-1)
	begin
		if(@FilterType=1)
			begin
				set @condition+=' and EndTime<GETDATE() and FinishStatus=1 '
			end
		else if(@FilterType=3 or @FilterType=2)
		begin
			set @condition+=' and EndTime>GETDATE() and FinishStatus=1 '

			if(@FilterType=2)
			begin
				set @condition+='and DateDiff(HH,GETDATE(),EndTime)*3< DateDiff(HH,AcceptTime,EndTime)'
			end
			else
			begin
				set @condition+='and DateDiff(HH,GETDATE(),EndTime)*3>= DateDiff(HH,AcceptTime,EndTime)'
			end
		end
		else if(@FilterType=4)
		begin
			set @condition+=' and FinishStatus=2 '
		end
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderColumn,@pageSize,@pageIndex,@total out,@page out,0 
	select @totalCount=@total,@pageCount =@page
	


