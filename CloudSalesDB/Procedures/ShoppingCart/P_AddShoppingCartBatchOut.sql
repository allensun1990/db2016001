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
@DepotID nvarchar(64),
@BatchCode nvarchar(50)='',
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@Remark nvarchar(max),
@OperateIP nvarchar(50)
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0

if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID  and OrderType=@OrderType and [GUID]=@GUID and BatchCode=@BatchCode and DepotID=@DepotID)
begin
	declare @Price decimal(18,4)=0
	select @Price=Price from ProductDetail where ProductDetailID=@ProductDetailID

	insert into ShoppingCart(OrderType,ProductDetailID,ProductID,DepotID,BatchCode,Quantity,Price,Remark,CreateTime,UserID,OperateIP,[GUID])
	values(@OrderType,@ProductDetailID,@ProductID,@DepotID,@BatchCode,@Quantity,@Price,@Remark,GETDATE(),@UserID,@OperateIP,@GUID)
end
else 
begin
	update ShoppingCart set Quantity=Quantity+@Quantity,Remark=@Remark 
	where  ProductDetailID=@ProductDetailID  and OrderType=@OrderType and [GUID]=@GUID and BatchCode=@BatchCode and DepotID=@DepotID
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