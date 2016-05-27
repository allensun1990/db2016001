Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrders')
BEGIN
	DROP  Procedure  P_GetOrders
END

GO
/***********************************************************
过程名称： P_GetOrders
功能描述： 获取客户订单列表
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_GetOrders 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrders]
	@SearchType int,
	@TypeID nvarchar(64)='',
	@Status int=-1,
	@PayStatus int=-1,
	@InvoiceStatus int=-1,
	@OrderStatus int=1,
	@ReturnStatus int=-1,
	@SourceType int=-1,
	@Mark int=-1,
	@SearchUserID nvarchar(64)='',
	@SearchTeamID nvarchar(64)='',
	@SearchAgentID nvarchar(64)='',
	@EntrustClientID nvarchar(64)='',
	@Keywords nvarchar(4000),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@OrderColumn nvarchar(4000)='',
	@pageSize int=20,
	@pageIndex int=1,
	@totalCount int output ,
	@pageCount int output,
	@UserID nvarchar(64)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@isAsc int

	select @tableName='Orders o left join Customer cus on o.CustomerID=cus.CustomerID',
	@columns='o.OrderID,o.OrderCode,o.OrderImage,o.OwnerID,o.OrderType,o.Status,o.TaskCount,o.TaskOver,o.PlanQuantity,o.FinalPrice,o.TotalMoney,o.Price,o.CustomerID,o.IntGoodsCode,o.EndTime,o.GoodsName,
			o.OrderStatus,o.CreateTime,o.PersonName,o.PlanPrice,o.PlanType,o.ProfitPrice,cus.Name CustomerName,o.AgentID,o.EntrustTime,o.SourceType,o.Mark,o.PlanTime,o.GoodsCode,o.OrderTime ',
	@key='o.AutoID',
	@isAsc=0

	set @condition='o.Status<>9 '

	create table #UserID(UserID nvarchar(64))

	if(@SearchType=1) --我的
	begin
		set @condition +=' and o.OwnerID = '''+@UserID+''''
	end
	else if(@SearchType=2) --下属
	begin
		if(@SearchUserID<>'')
		begin
			set @condition +=' and o.OwnerID = '''+@SearchUserID+''''
		end
		else
		begin
			with TempUser(UserID)
			as
			(
				select UserID from Users where ParentID=@UserID and Status<>9
				union all
				select u.UserID from Users u join TempUser t on u.ParentID=t.UserID and Status<>9
			)
			insert into #UserID select UserID from TempUser

			set @condition +=' and o.OwnerID in (select UserID from #UserID) '
		end
	end
	else if(@SearchType=4)--委托
	begin
		set @condition +=' and o.EntrustClientID = '''+@ClientID+''''
	end
	else if(@SearchType=5)--我协助的
	begin
		set @condition +=' and o.Status>0 and o.ClientID= '''+@ClientID+'''and  o.EntrustClientID <> '''''
	end
	else if(@SearchType=6)--我负责的
	begin
		set @condition +=' and o.Status>0  and o.ClientID= '''+@ClientID+'''and  o.EntrustClientID = '''''
	end
	else if(@SearchType=7)--我委托的
	begin
		set @condition +=' and o.Status>0  and o.EntrustClientID = '''+@ClientID+''''
	end
	else --工厂全部订单
	begin
		if(@SearchUserID<>'')
		begin
			set @condition +=' and o.OwnerID = '''+@SearchUserID+''''
		end
		else if(@SearchTeamID<>'')
		begin
			insert into #UserID select UserID from TeamUser where TeamID=@SearchTeamID and status=1
			set @condition +=' and o.OwnerID in (select UserID from #UserID) '
		end
		else if(@SearchAgentID<>'')
		begin
			set @condition +=' and o.AgentID = '''+@SearchAgentID+''''
		end
		else
		begin
			set @condition +=' and o.ClientID = '''+@ClientID+''''
		end
	end

	if(@TypeID<>'')
	begin
		set @condition +=' and o.OrderType = '+@TypeID
	end

	if(@SourceType<>-1)
	begin
		set @condition +=' and o.SourceType = '+convert(nvarchar(2), @SourceType)
	end

	if(@Status<>-1)
	begin
		set @condition +=' and o.Status = '+convert(nvarchar(2), @Status)
	end

	if(@PayStatus<>-1)
	begin
		set @condition +=' and o.PayStatus = '+convert(nvarchar(2), @PayStatus)
	end

	if(@ReturnStatus<>-1)
	begin
		set @condition +=' and o.ReturnStatus = '+convert(nvarchar(2), @ReturnStatus)
	end

	if(@OrderStatus<>-1)
	begin
		set @condition +=' and o.OrderStatus =  '+convert(nvarchar(2), @OrderStatus)
	end
	else
	begin
		set @condition +=' and o.OrderStatus <> 8  '
	end

	if(@InvoiceStatus=2)
	begin
		set @condition +=' and o.OrderStatus = 1 and o.PlanTime< GetDate() '
	end
	else if(@InvoiceStatus=1)
	begin
		set @condition +=' and o.OrderStatus = 1 and o.PlanTime > GetDate() and datediff(hour,o.Ordertime,o.PlanTime) > datediff(hour,GetDate(),o.PlanTime)*3 '
	end
	else if(@InvoiceStatus=0)
	begin
		set @condition +=' and o.OrderStatus = 1 and o.PlanTime > GetDate() and datediff(hour,o.Ordertime,o.PlanTime) <= datediff(hour,GetDate(),o.PlanTime)*3 '
	end

	if(@Mark<>-1)
	begin
		set @condition +=' and o.Mark = '+convert(nvarchar(2), @Mark)
	end

	if(@EntrustClientID = '1')
	begin
		set @condition +=' and o.EntrustClientID = '''''
	end
	else if(@EntrustClientID = '2')
	begin
		set @condition +=' and o.EntrustClientID <> '''''
	end

	if(@BeginTime<>'')
		set @condition +=' and o.PlanTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and o.PlanTime <=  '''+@EndTime+' 23:59:59'''

	if(@keyWords <> '')
	begin
		set @condition +=' and (o.OrderCode like ''%'+@keyWords+'%'' or o.Title like ''%'+@keyWords+'%'' or o.PersonName like ''%'+@keyWords+'%''  or o.GoodsCode like ''%'+@keyWords+'%''  or o.IntGoodsCode like ''%'+@keyWords+'%''  or o.GoodsName like ''%'+@keyWords+'%'' or o.MobileTele like ''%'+@keyWords+'%'')'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

