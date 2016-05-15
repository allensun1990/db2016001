Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_GetClientOrders')
BEGIN
	DROP  Procedure  M_GetClientOrders
END

GO
/***********************************************************
过程名称： M_GetClientOrders
功能描述： 查询客户订单列表
参数说明：	 
编写日期： 2015/12/4
程序作者： MU
调试记录： exec M_GetClientOrders 
************************************************************/
CREATE PROCEDURE [dbo].M_GetClientOrders
@Status int=-1,
@Type int=-1,
@BeginDate nvarchar(100),
@EndDate nvarchar(100),
@AgentID nvarchar(64),
@ClientID nvarchar(64),
@pageSize int,
@pageIndex int,
@totalCount int output,
@pageCount int output
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)
	
	set @tableName='ClientOrder'
	set @columns='*'
	set @key='AutoID'
	set @orderColumn='createtime desc'
	set @condition=' 1=1 '

	if(@AgentID<>'')
		set @condition+=' and AgentID='''+@AgentID+''''
	if(@ClientID<>'')
		set @condition+=' and clientID='''+@ClientID+''''

	if(@Status<>-1)
		set @condition=@condition+' and status='+str(@Status)
	if(@Type<>-1)
		set @condition=@condition+' and Type='+str(@Type)
	if(@BeginDate<>'')
		set @condition=@condition+' and createtime>='''+@BeginDate+''''
	if(@EndDate<>'')
		set @condition+=' and createtime<='''+dateadd(day, 1, @EndDate)+''''


	declare @total int,@page int

	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,0

	set @totalCount=@total
	set @pageCount =@page





