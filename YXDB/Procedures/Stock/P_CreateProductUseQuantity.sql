Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateProductUseQuantity')
BEGIN
	DROP  Procedure  P_CreateProductUseQuantity
END

GO
/***********************************************************
过程名称： P_CreateProductUseQuantity
功能描述： 添加材料用量
参数说明：	 
编写日期： 2016/8/4
程序作者： Allen
调试记录： exec P_CreateProductUseQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateProductUseQuantity]
@OrderID nvarchar(64),
@ProductsDetails nvarchar(4000),
@DocCode nvarchar(50),
@UserID nvarchar(64),
@OperateIP nvarchar(64),
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@Status int,@OrderCode nvarchar(50),@DocID nvarchar(64)=NewID(),
@DocImage nvarchar(2000),@DocImages nvarchar(4000)

select @Status=OrderStatus,@OrderCode=OrderCode,@DocImage=OrderImage,@DocImages=OrderImages from Orders where OrderID=@OrderID

if(@Status>1)
begin
	set @Result=2 
	set @ErrInfo='订单已完成！'
	rollback tran
	return
end

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity decimal(18,4),@DepotID nvarchar(64),@TotalMoney  decimal(18,4),
@sql nvarchar(4000),@GoodsQuantity nvarchar(200),@WareID nvarchar(64),@BatchAutoID int,@UseQuantity decimal(18,4),@BatchQuantity decimal(18,4)

create table #TempTable(ID int identity(1,1),Value nvarchar(4000))
set @sql='select col='''+ replace(@ProductsDetails,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)

select @WareID=WareID from WareHouse where ClientID=@ClientID and Status<>9

--货位临时库存表
create table #BatchStock(AutoID int identity(1,1),DepotID nvarchar(64),Quantity int)

while exists(select ID from #TempTable where ID=@AutoID)
begin
	select @GoodsQuantity=Value from #TempTable where ID=@AutoID
	if(LEN(@GoodsQuantity)>0)
	begin
		set @ProductDetailID= convert(nvarchar(64), SUBSTRING (@GoodsQuantity , 1 , CHARINDEX ('|' , @GoodsQuantity )-1))

		set @Quantity=convert(decimal(18,4), SUBSTRING (@GoodsQuantity , CHARINDEX ('|' , @GoodsQuantity)+1 ,LEN(@GoodsQuantity)- CHARINDEX ('|' , @GoodsQuantity)))

		if(@Quantity is null or @Quantity=0)
		begin
			set @AutoID+=1
			continue;
		end

		select @ProductID=ProductID,@UseQuantity=@Quantity from OrderDetail where OrderID=@OrderID and ProductDetailID=@ProductDetailID

		--更新材料用量
		Update OrderDetail set UseQuantity=UseQuantity+@Quantity where OrderID=@OrderID and ProductDetailID=@ProductDetailID

		--处理材料库存
		if exists(select AutoID from ClientProducts where ProductID=@ProductID and ClientID=@ClientID)
		begin
			Update ClientProducts set StockOut=StockOut+@UseQuantity,LogicOut=LogicOut+@UseQuantity where  ProductID=@ProductID and ClientID=@ClientID
		end
		else
		begin
			insert into ClientProducts(ProductID,ClientID,StockIn,StockOut,LogicOut)
								values(@ProductID,@ClientID,0,@UseQuantity,@UseQuantity)
		end
		set @Err+=@@Error

		--处理材料规格库存
		if exists(select AutoID from ClientProductDetails where ProductDetailID=@ProductDetailID and ClientID=@ClientID)
		begin
			Update ClientProductDetails set StockOut=StockOut+@UseQuantity,LogicOut=LogicOut+@UseQuantity where  ProductDetailID=@ProductDetailID and ClientID=@ClientID
		end
		else
		begin
			insert into ClientProductDetails(ProductID,ProductDetailID,ClientID,StockIn,StockOut,LogicOut)
								values(@ProductID,@ProductDetailID,@ClientID,0,@UseQuantity,@UseQuantity)
		end

		truncate table #BatchStock

		insert into #BatchStock(DepotID,Quantity) 
		select p.DepotID,StockIn-StockOut from ProductStock p join DepotSeat d on p.DepotID=d.DepotID
		where p.WareID=@WareID and ProductID=@ProductID and ProductDetailID=@ProductDetailID and StockIn-StockOut>0 order by d.Sort

		set @BatchAutoID=1

		--处理货位库存
		while exists(select AutoID from #BatchStock where AutoID=@BatchAutoID)
		begin
			select @DepotID=DepotID,@BatchQuantity=Quantity from #BatchStock where AutoID=@BatchAutoID 

			if(@BatchQuantity>=@UseQuantity)
			begin

				insert into StorageDetail(DocID,ProductDetailID,ProductID,ProviderID,UnitID,Quantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS )
				select @DocID,@ProductDetailID,@ProductID,ProviderID,UnitID,@UseQuantity,Price,Price*@UseQuantity,@WareID,@DepotID,0,Remark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
				from OrderDetail where OrderID=@OrderID and ProductDetailID=@ProductDetailID

				update ProductStock set StockOut=StockOut+@UseQuantity where ProductDetailID=@ProductDetailID  and DepotID=@DepotID 
				--处理产品流水
				insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
						values(@ProductDetailID,@ProductID,@DocID,@DocCode,CONVERT(varchar(100), GETDATE(), 112),3,1,@UseQuantity,@WareID,@DepotID,@UserID,@ClientID)
			
				set @UseQuantity=0
				break;
			end
			else
			begin
				insert into StorageDetail(DocID,ProductDetailID,ProductID,ProviderID,UnitID,Quantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS )
				select @DocID,@ProductDetailID,@ProductID,ProviderID,UnitID,@BatchQuantity,Price,Price*@BatchQuantity,@WareID,@DepotID,0,Remark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
				from OrderDetail where OrderID=@OrderID and ProductDetailID=@ProductDetailID

				update ProductStock set StockOut=StockOut+@BatchQuantity where ProductDetailID=@ProductDetailID  and DepotID=@DepotID 
				--处理产品流水
				insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
						values(@ProductDetailID,@ProductID,@DocID,@DocCode,CONVERT(varchar(100), GETDATE(), 112),3,1,@BatchQuantity,@WareID,@DepotID,@UserID,@ClientID)
			
				set @UseQuantity=@UseQuantity-@BatchQuantity
			end

			set @BatchAutoID=@BatchAutoID+1
		end

		--库存不足
		if(@UseQuantity > 0)
		begin
			select top 1 @DepotID=p.DepotID from ProductStock p join DepotSeat d on p.DepotID=d.DepotID
			where p.WareID=@WareID and ProductID=@ProductID and ProductDetailID=@ProductDetailID order by d.Sort 

			if exists(select AutoID from ProductStock where  ProductDetailID=@ProductDetailID and DepotID=@DepotID)
			begin
				update ProductStock set StockOut=StockOut+@UseQuantity where ProductDetailID=@ProductDetailID  and DepotID=@DepotID 
			end
			else
			begin
				insert into ProductStock(ProductDetailID,ProductID,StockIn,StockOut,LogicOut,WareID,DepotID,ClientID)
							values (@ProductDetailID,@ProductID,0,@UseQuantity,0,@WareID,@DepotID,@ClientID)
			end
				
			--处理产品流水
			insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
						values(@ProductDetailID,@ProductID,@DocID,@DocCode,CONVERT(varchar(100), GETDATE(), 112),3,1,@UseQuantity,@WareID,@DepotID,@UserID,@ClientID)
		end
	end
	set @AutoID+=1
end

if exists(select AutoID from StorageDetail where DocID=@DocID)
begin
	
	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
		values(@DocID,@DocCode,3,@DocImage,@DocImages,2,isnull(@TotalMoney,0),'','','',@WareID,@UserID,GETDATE(),'',@ClientID,@OrderID,@OrderCode)

	set @Err+=@@error
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