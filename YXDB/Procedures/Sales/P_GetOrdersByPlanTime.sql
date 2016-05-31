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
	@ClientID nvarchar(64)
AS
	declare @sql nvarchar(1000)

	set @sql='select * from orders where status<>9 and ClientID='''+@ClientID+''''

	if(@UserID<>'')
		set @sql+=' and OwnerID='''+@UserID+''''

	if(@StartPlanTime<>'')
		set @sql+=' and PlanTime>='''+@StartPlanTime+''''

	if(@EndPlanTime<>'')
		set @sql+=' and PlanTime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndPlanTime), 23)+''''

	exec(@sql)


