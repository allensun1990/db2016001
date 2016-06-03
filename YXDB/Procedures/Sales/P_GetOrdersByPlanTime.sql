Use IntFactory_dev
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
	@ClientID nvarchar(64)
AS
	declare @sql nvarchar(1000)

	set @sql='select cus.Name CustomerName,o.* from Orders o left join Customer cus on o.CustomerID=cus.CustomerID where o.status<>9 and o.OrderStatus in(1,2) and o.ClientID='''+@ClientID+''''

	if(@UserID<>'')
		set @sql+=' and o.OwnerID='''+@UserID+''''

	if(@StartPlanTime<>'')
		set @sql+=' and o.PlanTime>='''+@StartPlanTime+''''

	if(@EndPlanTime<>'')
		set @sql+=' and o.PlanTime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndPlanTime), 23)+''''

	if(@FilterType<>-1)
	begin
		if(@FilterType=1)
			begin
				set @sql+=' and o.PlanTime<GETDATE() and o.OrderStatus=1 '
			end
		else if(@FilterType=3 or @FilterType=2)
		begin
			set @sql+=' and o.PlanTime>GETDATE() and o.OrderStatus=1 '

			if(@FilterType=2)
			begin
				set @sql+='and DateDiff(HH,GETDATE(),o.PlanTime)*3< DateDiff(HH,o.OrderTime,o.PlanTime)'
			end
			else
			begin
				set @sql+='and DateDiff(HH,GETDATE(),o.PlanTime)*3>= DateDiff(HH,o.OrderTime,o.PlanTime)'
			end
		end
		else if(@FilterType=4)
		begin
			set @sql+=' and o.OrderStatus=2 '
		end
	end
	exec(@sql)


