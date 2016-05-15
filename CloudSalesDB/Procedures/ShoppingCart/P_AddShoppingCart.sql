Use [CloudSales1.0_dev]
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

declare @Err int=0,@Price decimal(18,4)=0,@TotalMoney decimal(18,4)=0

select @Price=Price from ProductDetail where ProductDetailID=@ProductDetailID

if(@OrderType=10 and exists(select AutoID from Opportunity where OpportunityID=@GUID and Status=1))
begin
	if not exists(select AutoID from OpportunityProduct where ProductDetailID=@ProductDetailID  and OpportunityID=@GUID)
	begin
		insert into OpportunityProduct(OpportunityID,ProductDetailID,ProductID,UnitID,Quantity,Price,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,CreateUserID)
		select @GUID,@ProductDetailID,@ProductID,@UnitID,@Quantity,d.Price,@Quantity*d.Price,d.Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,@UserID
	    from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
	end
	else 
	begin
		update OpportunityProduct set Quantity=Quantity+@Quantity,Remark=@Remark where ProductDetailID=@ProductDetailID and OpportunityID=@GUID
	end

	select @TotalMoney=sum(Quantity*Price) from OpportunityProduct where  OpportunityID=@GUID

	update Opportunity set TotalMoney=isnull(@TotalMoney,0) where OpportunityID=@GUID

end

--if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID  and IsBigUnit=@IsBigUnit and OrderType=@OrderType and [GUID]=@GUID)
--begin

--	insert into ShoppingCart(OrderType,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,Remark,CreateTime,UserID,OperateIP,[GUID])
--	values(@OrderType,@ProductDetailID,@ProductID,@UnitID,@IsBigUnit,@Quantity,@Price,@Remark,GETDATE(),@UserID,@OperateIP,@GUID)
--end
--else 
--begin
--	update ShoppingCart set Quantity=Quantity+@Quantity,Remark=@Remark where ProductDetailID=@ProductDetailID and [GUID]=@GUID and OrderType=@OrderType and IsBigUnit=@IsBigUnit 
--end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end