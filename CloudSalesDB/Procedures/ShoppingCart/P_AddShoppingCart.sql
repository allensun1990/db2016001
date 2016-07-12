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
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@Remark nvarchar(max),
@OperateIP nvarchar(50)
AS
begin tran

declare @Err int=0, @TotalMoney decimal(18,4)=0

if(@OrderType=10 and exists(select AutoID from Opportunity where OpportunityID=@GUID and Status=1)) --机会
begin
	if not exists(select AutoID from OpportunityProduct where ProductDetailID=@ProductDetailID  and OpportunityID=@GUID)
	begin
		insert into OpportunityProduct(OpportunityID,ProductDetailID,ProductID,UnitID,Quantity,Price,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,CreateUserID,ClientID)
		select @GUID,@ProductDetailID,@ProductID,UnitID,@Quantity,d.Price,@Quantity*d.Price,d.Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,@UserID,p.ClientID
	    from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
	end
	else 
	begin
		update OpportunityProduct set Quantity=Quantity+@Quantity,Remark=@Remark,TotalMoney=(Quantity+@Quantity)*Price where ProductDetailID=@ProductDetailID and OpportunityID=@GUID
	end

	select @TotalMoney=sum(TotalMoney) from OpportunityProduct where  OpportunityID=@GUID

	update Opportunity set TotalMoney=isnull(@TotalMoney,0) where OpportunityID=@GUID
end
else if(@OrderType=11 and exists(select AutoID from Orders where OrderID=@GUID and Status=1)) --订单
begin
	if not exists(select AutoID from OrderDetail where ProductDetailID=@ProductDetailID  and OrderID=@GUID)
	begin
		insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,Quantity,Price,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,CreateUserID,ClientID)
		select @GUID,@ProductDetailID,@ProductID,UnitID,@Quantity,d.Price,@Quantity*d.Price,d.Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,@UserID,p.ClientID
	    from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
	end
	else 
	begin
		update OrderDetail set Quantity=Quantity+@Quantity,Remark=@Remark,TotalMoney=(Quantity+@Quantity)*Price where ProductDetailID=@ProductDetailID and OrderID=@GUID
	end

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@GUID

	update Orders set TotalMoney=isnull(@TotalMoney,0) where OrderID=@GUID

end
else if(@OrderType=1) 
begin
	if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID and UserID=@UserID and OrderType=@OrderType and [GUID]=@GUID)
	begin
		insert into ShoppingCart(OrderType,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,ProviderName,CreateTime,UserID,OperateIP,[GUID])
		select @OrderType,@ProductDetailID,@ProductID,p.UnitID,0,@Quantity,d.Price,d.Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,p.ProviderID,pro.Name,GETDATE(),@UserID,@OperateIP,@GUID 
		from ProductDetail d join Products p on d.ProductID=p.ProductID 
		left join Providers pro on p.ProviderID=pro.ProviderID
		where d.ProductDetailID=@ProductDetailID 
	end
	else
	begin
		update ShoppingCart set Quantity=Quantity+@Quantity,Remark=@Remark where ProductDetailID=@ProductDetailID and [GUID]=@GUID and OrderType=@OrderType and UserID=@UserID
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