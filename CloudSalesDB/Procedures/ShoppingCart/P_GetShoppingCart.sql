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
调试记录： exec P_GetShoppingCart 1,'1104c2fd-e9b6-4ee5-b26d-aaa927cb15f6'
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
else
begin
	if(@UserID='')
	begin
		select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark Description,p.ProductName,u.UnitID,u.UnitName,
			s.Price,d.Imgs,s.BatchCode,s.DepotID,ds.DepotCode 
		from ShoppingCart s 
		join ProductDetail d on d.ProductDetailID=s.ProductDetailID
		join Products p  on s.ProductID=p.ProductID
		left join ProductUnit u on s.UnitID=u.UnitID
		left join DepotSeat ds on s.DepotID=ds.DepotID and s.DepotID<>''
		where s.[GUID]=@GUID and s.OrderType=@OrderType
	end
	else
	begin
		select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark Description,p.ProductName,u.UnitID,u.UnitName,
			 s.Price,d.Imgs,s.BatchCode,s.DepotID ,ds.DepotCode
		from ShoppingCart s 
		join ProductDetail d on d.ProductDetailID=s.ProductDetailID
		join Products p  on s.ProductID=p.ProductID
		left join ProductUnit u on s.UnitID=u.UnitID
		left join DepotSeat ds on s.DepotID=ds.DepotID and s.DepotID<>''
		where s.[GUID]=@GUID and s.OrderType=@OrderType and s.UserID=@UserID
	end
end


 

