Use IntFactory
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

if(@OrderType=11)
begin
	select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Loss,s.Remark Description,s.ProductName,s.UnitID,s.ProductCode,
			s.Price,s.Imgs,s.ProductImage,s.DepotID,B.Name ProviderName 
		from OrderDetail s 
		left join Providers b on s.ProviderID=B.ProviderID
		where s.OrderID=@GUID 
end
else
begin
	if(@UserID='')
	begin
		select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark Description,s.ProductName,s.UnitID,s.ProductCode,
			 s.Price, s.Imgs,s.ProductImage,s.DepotID ,B.Name ProviderName,dm.DepotCode
		from ShoppingCart s 
		left join Providers b on s.ProviderID=B.ProviderID
		left join DepotSeat dm on s.DepotID=dm.DepotID 
		where s.[GUID]=@GUID and s.OrderType=@OrderType
	end
	else
	begin
		select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark Description,s.ProductName,s.UnitID,s.ProductCode,
			 s.Price, s.Imgs,s.ProductImage,s.DepotID ,B.Name ProviderName,dm.DepotCode
		from ShoppingCart s 
		left join Providers b on s.ProviderID=B.ProviderID
		left join DepotSeat dm on s.DepotID=dm.DepotID 
		where s.[GUID]=@GUID and s.OrderType=@OrderType and s.UserID=@UserID
	end
end


 

