Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddShoppingCart')
BEGIN
	DROP  Procedure  P_AddShoppingCart
END

GO
/***********************************************************
过程名称： P_AddShoppingCart
功能描述： 加入购物车
参数说明：	 
编写日期： 2015/9/15
程序作者： Allen
调试记录： exec P_AddShoppingCart 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddShoppingCart]
@OrderType int,
@ProductDetailID nvarchar(64),
@ProductID nvarchar(64),
@Quantity int=1,
@UnitID nvarchar(64),
@IsBigUnit int=0,
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@Remark nvarchar(max),
@OperateIP nvarchar(50)
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0

if(@OrderType=11)
begin
	
	if not exists(select AutoID from OrderDetail where OrderID=@GUID and ProductDetailID=@ProductDetailID)
	begin
		insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,Quantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID)
		select @GUID,@ProductDetailID,@ProductID,@UnitID,@Quantity,d.Price,0,@Quantity*d.Price,isnull(d.Description,'')+isnull(d.Remark,''),ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID
	    from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
	end
	else
	begin
		update OrderDetail set Quantity=Quantity+@Quantity,TotalMoney=(Quantity+@Quantity+Loss)*Price where OrderID=@GUID and ProductDetailID=@ProductDetailID
	end

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@GUID

	update Orders set Price=isnull(@TotalMoney,0),TotalMoney=isnull(@TotalMoney,0)*PlanQuantity where OrderID=@GUID
end
else
begin
	if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID and OrderType=@OrderType and [GUID]=@GUID)
	begin
		
		insert into ShoppingCart(OrderType,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,Remark,CreateTime,UserID,OperateIP,[GUID],ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID)
		select @OrderType,@ProductDetailID,@ProductID,@UnitID,0,@Quantity,d.Price,isnull(d.Description,'')+isnull(d.Remark,''),GETDATE(),@UserID,@OperateIP,@GUID ,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID
		from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID

	end
	else 
	begin
		update ShoppingCart set Quantity=Quantity+@Quantity,Remark=@Remark 
		where ProductDetailID=@ProductDetailID and [GUID]=@GUID and OrderType=@OrderType
	end
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