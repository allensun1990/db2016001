Use IntFactory
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
	@SearchOrderType int,
	@SearchType int,
	@TypeID nvarchar(64)='',
	@Status int=-1,
	@PayStatus int=-1,
	@WarningStatus int=-1,
	@OrderStatus int=1,
	@PublicStatus int=-1,
	@ReturnStatus int=-1,
	@SourceType int=-1,
	@Mark int=-1,
	@SearchUserID nvarchar(64)='',
	@SearchTeamID nvarchar(64)='',
	@EntrustType nvarchar(10)='',
	@Keywords nvarchar(4000),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@OrderColumn nvarchar(4000)='',
	@pageSize int=20,
	@pageIndex int=1,
	@totalCount int output ,
	@pageCount int output,
	@UserID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@isAsc int

	select @tableName='Orders o',
	@columns='o.* ',
	@key='o.AutoID',
	@isAsc=0

	set @condition='o.Status<>9 '

	create table #UserID(UserID nvarchar(64))

	if(@SearchOrderType=0)
	begin
		set @condition +=' and o.Status = 0 ';
	end
	else if(@SearchOrderType=1)
	begin
		set @condition +=' and o.OrderType = 1 ';
	end
	else if(@SearchOrderType=2)
	begin
		set @condition +=' and o.OrderType = 2 ';
	end

	if(@SearchType=1) --我的
	begin
		set @condition +=' and (o.OwnerID = '''+@UserID+''' or o.CreateUserID= '''+@UserID+''')'
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
	end

	if(@EntrustType = '1')
	begin
		set @condition +=' and o.ClientID = '''+@ClientID+''' and o.EntrustClientID = '''''
	end
	else if(@EntrustType = '2')
	begin
		set @condition +='  and o.EntrustClientID = '''+@ClientID+''''
	end
	else if(@EntrustType = '3')
	begin
		set @condition +=' and o.ClientID = '''+@ClientID+''' and o.EntrustClientID <> '''''
	end
	else
	begin
		set @condition +=' and (o.ClientID = '''+@ClientID+''' or o.EntrustClientID='''+@ClientID+''')'
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
		set @condition +=' and o.OrderStatus <> 8 '
	end

	if(@PublicStatus<>-1)
	begin
		set @condition +=' and o.IsPublic =  '+convert(nvarchar(2), @PublicStatus)
	end

	if(@WarningStatus=2)
	begin
		set @condition +=' and o.OrderStatus = 1 and o.PlanTime< GetDate() '
	end
	else if(@WarningStatus=1)
	begin
		set @condition +=' and o.OrderStatus = 1 and o.PlanTime > GetDate() and datediff(hour,o.Ordertime,o.PlanTime) > datediff(hour,GetDate(),o.PlanTime)*3 '
	end
	else if(@WarningStatus=0)
	begin
		set @condition +=' and o.OrderStatus = 1 and o.PlanTime > GetDate() and datediff(hour,o.Ordertime,o.PlanTime) <= datediff(hour,GetDate(),o.PlanTime)*3 '
	end

	if(@Mark<>-1)
	begin
		set @condition +=' and o.Mark = '+convert(nvarchar(2), @Mark)
	end

	if(@BeginTime<>'')
		set @condition +=' and o.PlanTime >= '''+@BeginTime+' 0:00:00''';

	if(@EndTime<>'')
		set @condition +=' and o.PlanTime <=  '''+@EndTime+' 23:59:59''';

	if(@keyWords <> '')
	begin
		set @condition +=' and (o.OrderCode like ''%'+@keyWords+'%'' or o.Title like ''%'+@keyWords+'%'' or o.PersonName like ''%'+@keyWords+'%''  or o.GoodsCode like ''%'+@keyWords+'%''  or o.IntGoodsCode like ''%'+@keyWords+'%''  or o.GoodsName like ''%'+@keyWords+'%'' or o.MobileTele like ''%'+@keyWords+'%'')'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

