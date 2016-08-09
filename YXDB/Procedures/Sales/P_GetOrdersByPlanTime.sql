Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrdersByPlanTime')
BEGIN
	DROP  Procedure  P_GetOrdersByPlanTime
END

GO
/***********************************************************
过程名称： P_GetOrdersByPlanTime
功能描述： 获取订单列表根据交货时间
参数说明：	 
编写日期： 2016/5/31
程序作者： MU
调试记录： exec P_GetOrdersByPlanTime 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrdersByPlanTime]
	@StartPlanTime nvarchar(100)='',
	@EndPlanTime nvarchar(100)='',
	@UserID nvarchar(64)='',
	@FilterType int =-1,
	@OrderType int =-1,
	@OrderStatus int=-1,
	@ClientID nvarchar(64),
	@AndWhere nvarchar(4000)='',
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
	
	set @tableName='Orders o '
	set @columns='o.*'
	set @key='o.AutoID'
	set @orderColumn='PlanTime'
	set @condition='o.status<>9  and (o.ClientID='''+@ClientID+''' or o.EntrustClientID='''+@ClientID+''')' + @AndWhere

	if(@UserID<>'')
	begin
		set @condition+=' and (o.OwnerID='''+@UserID+''' or o.CreateUserID='''+@UserID+''')'
	end

	if(@OrderType<>-1)
		set @condition+=' and o.OrderType='+convert(nvarchar(2), @OrderType)

	if(@OrderStatus=-1)
		set @condition+=' and o.OrderStatus in(1,2)'
	else
		set @condition+=' and o.OrderStatus='+convert(nvarchar(2), @OrderStatus)

	if(@StartPlanTime<>'')
		set @condition+=' and o.PlanTime>='''+@StartPlanTime+''''

	if(@EndPlanTime<>'')
		set @condition+=' and o.PlanTime<'''+CONVERT(varchar(100), dateadd(day, 1, @EndPlanTime), 23)+''''

	if(@FilterType<>-1)
	begin
		if(@FilterType=1)
		begin
			set @condition+=' and o.PlanTime<GETDATE() and o.OrderStatus=1 and o.status<>4'
		end
		else if(@FilterType=3 or @FilterType=2)
		begin
			set @condition+=' and o.PlanTime>GETDATE() and o.OrderStatus=1 and o.status<>4 '

			if(@FilterType=2)
			begin
				set @condition+='and DateDiff(HH,GETDATE(),o.PlanTime)*3< DateDiff(HH,o.OrderTime,o.PlanTime)'
			end
			else
			begin
				set @condition+='and DateDiff(HH,GETDATE(),o.PlanTime)*3>= DateDiff(HH,o.OrderTime,o.PlanTime)'
			end
		end
		else if(@FilterType=4)
		begin
			set @condition+=' and o.OrderStatus=2 '
		end
	end
	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderColumn,@pageSize,@pageIndex,@total out,@page out,0 
	select @totalCount=@total,@pageCount =@page


