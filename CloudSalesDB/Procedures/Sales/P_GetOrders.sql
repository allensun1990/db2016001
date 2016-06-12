Use [CloudSales1.0_dev]
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
	@ReturnStatus int=-1,
	@SearchUserID nvarchar(64)='',
	@SearchTeamID nvarchar(64)='',
	@SearchAgentID nvarchar(64)='',
	@Keywords nvarchar(4000)='',
	@OrderBy nvarchar(500)='',
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@pageSize int,
	@pageIndex int,
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
	@orderColumn nvarchar(4000),
	@isAsc int

	select @tableName='Orders o join Customer cus on o.CustomerID=cus.CustomerID left join Billing b on o.OrderID=b.OrderID',
	@columns='o.*,cus.Name CustomerName,b.PayMoney,b.PayStatus,b.InvoiceStatus ',
	@key='o.AutoID',
	@isAsc=0

	set @condition='o.ClientID='''+@ClientID+''' and o.Status<>9 '

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
	else --全部
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
	end

	if(@TypeID<>'')
	begin
		set @condition +=' and o.TypeID = '''+@TypeID+''''
	end

	if(@Status<>-1)
	begin
		set @condition +=' and o.Status = '+convert(nvarchar(2), @Status)
	end
	else
	begin
		set @condition +=' and o.Status > 0 '
	end

	if(@PayStatus<>-1)
	begin
		set @condition +=' and b.PayStatus = '+convert(nvarchar(2), @PayStatus)
	end

	if(@InvoiceStatus<>-1)
	begin
		set @condition +=' and b.InvoiceStatus = '+convert(nvarchar(2), @InvoiceStatus)
	end

	if(@ReturnStatus<>-1)
	begin
		set @condition +=' and o.ReturnStatus = '+convert(nvarchar(2), @ReturnStatus)
	end

	if(@BeginTime<>'')
		set @condition +=' and o.CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and o.CreateTime <=  '''+@EndTime+' 23:59:59'''

	if(@keyWords <> '')
	begin
		set @condition +=' and (o.OrderCode like ''%'+@keyWords+'%'' or cus.Name like ''%'+@keyWords+'%'' or o.PersonName like ''%'+@keyWords+'%'')'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderBy,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

