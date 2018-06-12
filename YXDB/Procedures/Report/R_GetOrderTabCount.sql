Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetOrderTabCount')
BEGIN
	DROP  Procedure  R_GetOrderTabCount
END

GO
/***********************************************************
过程名称： R_GetOrderTabCount
功能描述： 订单tab数量
参数说明：	 
编写日期： 2018/6/12
程序作者： Allen
调试记录： exec R_GetOrderTabCount '','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetOrderTabCount]
	@UserID nvarchar(64)='',
	@ClientID nvarchar(64)
AS

	create table #ResultDate(OrderType int,OrderStatus int,OrderQuantity int)

	if(@UserID is null or @UserID='')
	begin
		--未归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select OrderType,OrderStatus,count(0) OrderQuantity from Orders
		where Status<>9 and ArchivingStatus=0 and ( ClientID=@ClientID or EntrustClientID=@ClientID)
		group by OrderType,OrderStatus 
		--归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select OrderType,999,count(0) OrderQuantity from Orders
		where  ArchivingStatus=1 and ( ClientID=@ClientID or EntrustClientID=@ClientID)
		group by OrderType
	end
	else
	begin
		--未归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select OrderType,OrderStatus,count(0) OrderQuantity from Orders
		where Status<>9 and ArchivingStatus=0 and OwnerID=@UserID
		group by OrderType,OrderStatus 
		--归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select OrderType,999,count(0) OrderQuantity from Orders
		where  ArchivingStatus=1 and OwnerID=@UserID
		group by OrderType
	end
	select * from #ResultDate
	drop table #ResultDate


 

