Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetShoppingCart')
BEGIN
	DROP  Procedure  P_GetShoppingCart
END

GO
/***********************************************************
过程名称： P_GetShoppingCart
功能描述： 获取购物车详情
参数说明：	 
编写日期： 2015/7/1
程序作者： Allen
调试记录： exec P_GetShoppingCart 1,'e011258f-e5d6-49d2-baa5-2abba62ca921','e011258f-e5d6-49d2-baa5-2abba62ca921'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetShoppingCart]
	@OrderType int,
	@GUID nvarchar(64),
	@UserID nvarchar(64)=''
AS

if(@OrderType=10)
begin
	select * from OpportunityProduct where OpportunityID=@GUID
end
else if(@OrderType=11)
begin
	select * from OrderDetail where OrderID=@GUID
end
else if(@OrderType=1)
begin
	select * from ShoppingCart 
	where [GUID]=@GUID and OrderType=@OrderType 
end
else
begin
	select s.*,ds.DepotCode from ShoppingCart s 
	left join DepotSeat ds on s.DepotID=ds.DepotID and s.DepotID<>''
	where s.[GUID]=@GUID and s.OrderType=@OrderType 
end


 

