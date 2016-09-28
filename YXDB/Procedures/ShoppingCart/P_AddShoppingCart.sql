Use IntFactory
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
@Quantity decimal(18,4)=1,
@UnitID nvarchar(64),
@DepotID nvarchar(64)='',
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@OrderAttrID nvarchar(64)='',
@Remark nvarchar(max),
@OperateIP nvarchar(50),
@TaskID nvarchar(64)=''
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0,@PlanQuantity int,@Type int,@AttrName nvarchar(100),@AvgPrice decimal(18,4)

--订单或者任务
if(@OrderType=11)
begin
	select @PlanQuantity=PlanQuantity,@Type=OrderType from Orders where OrderID=@GUID

	if(@TaskID<>'' and exists(select AutoID from OrderTask where TaskID=@TaskID and FinishStatus=2 and LockStatus=1 ))
	begin
		rollback tran
		return
	end

	--打样单单
	if(@Type=1) 
	begin
		select @AttrName=AttrName from OrderAttrs where OrderAttrID=@OrderAttrID

		if not exists(select AutoID from OrderDetail where OrderID=@GUID and ProductDetailID=@ProductDetailID and OrderAttrID=@OrderAttrID)
		begin
			insert into OrderDetail(OrderID,OrderAttrID,SalesAttr,ProductDetailID,ProductID,UnitID,OrderQuantity,Quantity,PlanQuantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID)
			select @GUID,@OrderAttrID,@AttrName,@ProductDetailID,@ProductID,p.UnitID,1,@Quantity,@Quantity,d.Price,0,@Quantity*d.Price,isnull(d.Description,'')+isnull(d.Remark,''),ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID
			from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
		end
		else
		begin
			update OrderDetail set Quantity=Quantity+@Quantity,PlanQuantity=(Quantity+@Quantity),TotalMoney=(Quantity+@Quantity)*Price 
			where OrderID=@GUID and ProductDetailID=@ProductDetailID and OrderAttrID=@OrderAttrID 
		end

		select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@GUID and OrderAttrID=@OrderAttrID

		update OrderAttrs set Price=isnull(@TotalMoney,0) where OrderAttrID=@OrderAttrID

		select @AvgPrice=avg(Price) from OrderAttrs where OrderID=@GUID and Price>0

		update Orders set Price=isnull(@AvgPrice,0) where OrderID=@GUID
	end
	else
	begin
		if not exists(select AutoID from OrderDetail where OrderID=@GUID and ProductDetailID=@ProductDetailID)
		begin
			insert into OrderDetail(OrderID,OrderAttrID,SalesAttr,ProductDetailID,ProductID,UnitID,OrderQuantity,Quantity,PlanQuantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID)
			select @GUID,@OrderAttrID,@AttrName,@ProductDetailID,@ProductID,p.UnitID,@PlanQuantity,@Quantity,@PlanQuantity*@Quantity,d.Price,0,@PlanQuantity*@Quantity*d.Price,isnull(d.Description,'')+isnull(d.Remark,''),ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID
			from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
		end

		select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@GUID

		update Orders set Price=isnull(@TotalMoney,0) where OrderID=@GUID
	end
end
else if(@OrderType=3) --报损
begin
	if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID and OrderType=@OrderType and [GUID]=@GUID and DepotID=@DepotID)
	begin
		insert into ShoppingCart(OrderType,ProductDetailID,ProductID,DepotID,UnitID,Quantity,Price,Remark,CreateTime,UserID,OperateIP,[GUID],ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID)
		select @OrderType,@ProductDetailID,@ProductID,@DepotID,p.UnitID,@Quantity,d.Price,isnull(d.Description,'')+isnull(d.Remark,''),GETDATE(),@UserID,@OperateIP,@GUID ,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID
		from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
	end
	else 
	begin
		update ShoppingCart set Quantity=Quantity+@Quantity where ProductDetailID=@ProductDetailID and [GUID]=@GUID and OrderType=@OrderType and DepotID=@DepotID
	end
end
else
begin
	if not exists(select AutoID from ShoppingCart where ProductDetailID=@ProductDetailID and OrderType=@OrderType and [GUID]=@GUID)
	begin
		insert into ShoppingCart(OrderType,ProductDetailID,ProductID,DepotID,UnitID,Quantity,Price,Remark,CreateTime,UserID,OperateIP,[GUID],ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID)
		select @OrderType,@ProductDetailID,@ProductID,@DepotID,p.UnitID,@Quantity,d.Price,isnull(d.Description,'')+isnull(d.Remark,''),GETDATE(),@UserID,@OperateIP,@GUID ,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID
		from ProductDetail d join Products p  on d.ProductID=p.ProductID where d.ProductDetailID=@ProductDetailID
	end
	else 
	begin
		if(@DepotID='')
		begin
			update ShoppingCart set Quantity=Quantity+@Quantity where ProductDetailID=@ProductDetailID and [GUID]=@GUID and OrderType=@OrderType
		end
		else
		begin
			update ShoppingCart set Quantity=Quantity+@Quantity,DepotID=@DepotID where ProductDetailID=@ProductDetailID and [GUID]=@GUID and OrderType=@OrderType
		end
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