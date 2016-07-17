Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddShoppingCartBatchOut')
BEGIN
	DROP  Procedure  P_AddShoppingCartBatchOut
END

GO
/***********************************************************
过程名称： P_AddShoppingCartBatchOut
功能描述： 加入购物车
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录： exec P_AddShoppingCartBatchOut 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddShoppingCartBatchOut]
@OrderType int,
@ProductDetailID nvarchar(64),
@ProductID nvarchar(64),
@Quantity int=1,
@WareID nvarchar(64)='',
@DepotID nvarchar(64),
@BatchCode nvarchar(50)='',
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@Remark nvarchar(max),
@OperateIP nvarchar(50)
AS
begin tran

declare @Err int=0

if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID  and OrderType=@OrderType and [GUID]=@GUID and UserID=@UserID and BatchCode=@BatchCode and DepotID=@DepotID)
begin
	insert into ShoppingCart(OrderType,ProductDetailID,ProductID,UnitID,UnitName,WareID,DepotID,BatchCode,Quantity,Price,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,CreateTime,UserID,OperateIP,[GUID])
	select @OrderType,@ProductDetailID,@ProductID,p.UnitID,u.UnitName,@WareID,@DepotID,@BatchCode,@Quantity,d.Price,d.Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,GETDATE(),@UserID,@OperateIP,@GUID 
	from ProductDetail d join Products p on d.ProductID=p.ProductID left join ProductUnit u on p.UnitID=u.UnitID where d.ProductDetailID=@ProductDetailID 
end
else 
begin
	update ShoppingCart set Quantity=Quantity+@Quantity,Remark=@Remark 
	where  ProductDetailID=@ProductDetailID  and OrderType=@OrderType and [GUID]=@GUID and BatchCode=@BatchCode and DepotID=@DepotID and UserID=@UserID
end


set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end