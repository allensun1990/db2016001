Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetAgentOrders')
BEGIN
	DROP  Procedure  P_GetAgentOrders
END

GO
/***********************************************************
过程名称： P_GetAgentOrders
功能描述： 获取代理商订单列表
参数说明：	 
编写日期： 2015/11/21
程序作者： Allen
调试记录： exec P_GetAgentOrders 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetAgentOrders]
	@Status int=-1,
	@OutStatus int=-1,
	@SendStatus int=-1,
	@ReturnStatus int=-1,
	@SearchAgentID nvarchar(64)='',
	@Keywords nvarchar(4000),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output,
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@orderColumn nvarchar(4000),
	@isAsc int

	select @tableName='AgentsOrders o',
	@columns='o.*',
	@key='o.AutoID',
	@orderColumn='o.CreateTime desc',
	@isAsc=0

	set @condition='o.ClientID='''+@ClientID+''' and o.Status<>9 '

	if(@SearchAgentID<>'')
	begin
		set @condition +=' and o.AgentID = '''+@SearchAgentID+''''
	end

	if(@Status<>-1)
	begin
		set @condition +=' and o.Status = '+convert(nvarchar(2), @Status)
	end

	if(@OutStatus<>-1)
	begin
		set @condition +=' and o.OutStatus = '+convert(nvarchar(2), @OutStatus)
	end

	if(@SendStatus=1)
	begin
		set @condition +=' and o.SendStatus <= '+convert(nvarchar(2), @SendStatus)
	end
	else if(@SendStatus=2)
	begin
		set @condition +=' and o.SendStatus = '+convert(nvarchar(2), @SendStatus)
	end
	

	if(@ReturnStatus<>-1 and @ReturnStatus<10)
	begin
		set @condition +=' and o.ReturnStatus = '+convert(nvarchar(2), @ReturnStatus)
	end
	else if(@ReturnStatus=11)
	begin
		set @condition +=' and o.ReturnStatus >0 '
	end

	if(@BeginTime<>'')
		set @condition +=' and o.CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and o.CreateTime <=  '''+@EndTime+' 23:59:59'''

	if(@keyWords <> '')
	begin
		set @condition +=' and (o.OrderCode like ''%'+@keyWords+'%'' or o.OriginalCode  like ''%'+@keyWords+'%'' or o.DocCode  like ''%'+@keyWords+'%'' or o.ExpressCode  like ''%'+@keyWords+'%''  or o.PersonName  like ''%'+@keyWords+'%'' or o.MobileTele like ''%'+@keyWords+'%'')'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

