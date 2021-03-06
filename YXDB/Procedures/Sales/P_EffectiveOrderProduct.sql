﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_EffectiveOrderProduct')
BEGIN
	DROP  Procedure  P_EffectiveOrderProduct
END

GO
/***********************************************************
过程名称： P_EffectiveOrderProduct
功能描述： 生效大货订单材料采购
参数说明：	 
编写日期： 2016/3/8
程序作者： Allen
调试记录： exec P_EffectiveOrderProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_EffectiveOrderProduct]
	@OrderID nvarchar(64),
	@BillingCode nvarchar(50),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS
	
begin tran

set @Result=0

declare @Err int=0,@Status int,@PlanQuantity decimal(18,4),@OrderCode nvarchar(64),@Stock decimal(18,4),@PurchaseStatus int,@DocImage nvarchar(4000),@DocImages nvarchar(64)

select @Status=Status,@OrderCode=OrderCode,@PurchaseStatus=PurchaseStatus,@DocImage=OrderImage,@DocImages=OrderImages 
from Orders where OrderID=@OrderID  and (ClientID=@ClientID or EntrustClientID=@ClientID)


--生成采购清单
if exists(select AutoID from OrderDetail where OrderID=@OrderID)
begin
			
	declare @DocID nvarchar(64)=NEWID(),@WareID nvarchar(64),@DepotID nvarchar(64),@TotalMoney decimal(18,4)

	select @WareID=WareID from WareHouse where ClientID=@ClientID and Status<>9

	--参数
	declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity decimal(18,2),
	@DRemark nvarchar(4000),@Price decimal(18,4),@UnitID nvarchar(64),@ProviderID nvarchar(64)=''

	select identity(int,1,1) as AutoID,ProductDetailID,ProductID, UnitID,PlanQuantity Quantity,Price,Remark,ProviderID,
	ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
	into #TempProducts 
	from OrderDetail where OrderID=@OrderID 

	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@DRemark=Remark,@Price=Price,
		@UnitID=UnitID,@ProviderID= ProviderID
		from #TempProducts where AutoID=@AutoID

		if(@Quantity is null or @Quantity=0)
		begin
			set @AutoID+=1
			continue;
		end

		if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID)
		begin
			select top 1 @DepotID= DepotID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID  order by AutoID desc
		end
		else
		begin
			select top 1 @DepotID = DepotID from DepotSeat where WareID=@WareID and Status=1 order by Sort 
		end

		insert into StorageDetail(DocID,ProductDetailID,ProductID,ProviderID,UnitID,Quantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS )
			select @DocID,@ProductDetailID,@ProductID,@ProviderID,@UnitID,@Quantity,@Price,@Price*@Quantity,@WareID,@DepotID,0,@DRemark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
			from #TempProducts where AutoID=@AutoID
		
		Update OrderDetail set PurchaseQuantity=PurchaseQuantity+@Quantity,PlanQuantity=0,OrderQuantity=0 where OrderID=@OrderID and ProductDetailID=@ProductDetailID

		set @Err+=@@Error

		set @AutoID=@AutoID+1
	end

	if exists(select AutoID from StorageDetail where DocID= @DocID)
	begin
		select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

		insert into StorageDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
		values(@DocID,@BillingCode,1,@DocImage,@DocImages,0,@TotalMoney,'','','大货单自动生成采购清单',@WareID,@OperateID,GETDATE(),'',@ClientID,@OrderID,@OrderCode)
		
		Update Orders set PurchaseStatus=1 where OrderID=@OrderID
	end
end

set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 

