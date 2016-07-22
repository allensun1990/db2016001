Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddShoppingCartBatchIn')
BEGIN
	DROP  Procedure  P_AddShoppingCartBatchIn
END

GO
/***********************************************************
过程名称： P_AddShoppingCartBatchIn
功能描述： 加入购物车
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录： exec P_AddShoppingCartBatchIn 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddShoppingCartBatchIn]
@OrderType int,
@ProductDetailID nvarchar(64),
@ProductID nvarchar(64),
@Quantity decimal(18,4)=1,
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@Remark nvarchar(max),
@OperateIP nvarchar(50)
AS
begin tran

declare @Err int=0

if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID  and OrderType=@OrderType and [GUID]=@GUID)
begin
	insert into ShoppingCart(OrderType,ProductDetailID,ProductID,UnitID,DepotID,BatchCode,Quantity,Price,Remark,CreateTime,UserID,OperateIP,[GUID],ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID)
	select @OrderType,@ProductDetailID,@ProductID,p.SmallUnitID,'','',@Quantity,d.Price,isnull(d.Description,'')+isnull(d.Remark,''),GETDATE(),@UserID,@OperateIP,@GUID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID
	from ProductDetail d join Products p on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
end
else 
begin
	update ShoppingCart set Quantity=Quantity+@Quantity where  ProductDetailID=@ProductDetailID  and OrderType=@OrderType and [GUID]=@GUID
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