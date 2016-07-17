Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditStorageIn')
BEGIN
	DROP  Procedure  P_AuditStorageIn
END

GO
/***********************************************************
过程名称： P_AuditStorageIn
功能描述： 采购审核
参数说明：	 
编写日期： 2015/9/24
程序作者： Allen
调试记录： exec P_AuditStorageIn 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditStorageIn]
@DocID nvarchar(64),
@DocType int,
@ProductsDetails nvarchar(4000),
@IsOver int=0,
@Remark nvarchar(4000)='',
@BillingCode nvarchar(50),
@UserID nvarchar(64),
@OperateIP nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@Status int,@DocCode nvarchar(50),@WareID nvarchar(64),@TotalMoney decimal(18,4),@NewDocID nvarchar(64)=NEWID(),@OriginalID  nvarchar(64)

select @Status=Status,@DocCode=DocCode,@WareID=WareID,@TotalMoney=TotalMoney,@OriginalID=OriginalID from StorageDoc where DocID=@DocID

if(@Status>1)
begin
	set @Result=2 
	set @ErrInfo='采购单已完成操作！'
	rollback tran
	return
end

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity decimal(18,4),@BatchCode nvarchar(50),@DepotID nvarchar(64),
@sql nvarchar(4000),@GoodsQuantity nvarchar(200),@GoodsAutoID nvarchar(64)

create table #TempTable(ID int identity(1,1),Value nvarchar(4000))
set @sql='select col='''+ replace(@ProductsDetails,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)

while exists(select ID from #TempTable where ID=@AutoID)
begin
	select @GoodsQuantity=Value from #TempTable where ID=@AutoID
	if(LEN(@GoodsQuantity)>0)
	begin
		set @GoodsAutoID= convert(int, SUBSTRING (@GoodsQuantity , 1 , CHARINDEX ('-' , @GoodsQuantity )-1))

		set @Quantity=convert(decimal(18,4), SUBSTRING (@GoodsQuantity , CHARINDEX ('-' , @GoodsQuantity)+1 ,CHARINDEX (':' , @GoodsQuantity)- CHARINDEX ('-' , @GoodsQuantity)-1))

		set @DepotID=SUBSTRING (@GoodsQuantity , CHARINDEX (':' , @GoodsQuantity)+1 ,LEN(@GoodsQuantity)- CHARINDEX (':' , @GoodsQuantity))

		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@BatchCode=BatchCode from StorageDetail where DocID=@DocID and AutoID=@GoodsAutoID

		if(@Quantity is null or @Quantity=0)
		begin
			set @AutoID+=1
			continue;
		end

		--处理材料库存
		if exists(select AutoID from ClientProducts where ProductID=@ProductID and ClientID=@ClientID)
		begin
			Update ClientProducts set StockIn=StockIn+@Quantity where  ProductID=@ProductID and ClientID=@ClientID
		end
		else
		begin
			insert into ClientProducts(ProductID,ClientID,StockIn,StockOut,LogicOut)
								values(@ProductID,@ClientID,@Quantity,0,0)
		end
		set @Err+=@@Error

		--处理材料规格库存
		if exists(select AutoID from ClientProductDetails where ProductDetailID=@ProductDetailID and ClientID=@ClientID)
		begin
			Update ClientProductDetails set StockIn=StockIn+@Quantity where  ProductDetailID=@ProductDetailID and ClientID=@ClientID
		end
		else
		begin
			insert into ClientProductDetails(ProductID,ProductDetailID,ClientID,StockIn,StockOut,LogicOut)
								values(@ProductID,@ProductDetailID,@ClientID,@Quantity,0,0)
		end
		set @Err+=@@Error

		--处理材料实际库存明细
		if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID  and ClientID=@ClientID)
		begin
			update ProductStock set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID and ClientID=@ClientID
		end
		else
		begin
			insert into ProductStock(ProductDetailID,ProductID,StockIn,StockOut,BatchCode,WareID,DepotID,ClientID)
								values (@ProductDetailID,@ProductID,@Quantity,0,@BatchCode,@WareID,@DepotID,@ClientID)
		end
		set @Err+=@@Error

		--处理产品流水
		insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
							values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),@DocType,0,@Quantity,@WareID,@DepotID,@UserID,@ClientID)

		--修改产品入库数
		--update Products set StockIn=StockIn+@Quantity where ProductID=@ProductID

		--修改产品明细入库数
		--update ProductDetail set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID
		set @Err+=@@Error

		--更新已入库数量
		Update StorageDetail set Complete=Complete+@Quantity,DepotID=@DepotID where  AutoID=@GoodsAutoID and DocID=@DocID

		insert into StorageDetail(DocID,ProductDetailID,ProductID,ProdiverID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS )
			select @NewDocID,ProductDetailID,ProductID,ProdiverID,UnitID,0,@Quantity,Price,Price*@Quantity,WareID,@DepotID,BatchCode,0,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
			from StorageDetail where AutoID=@GoodsAutoID and DocID=@DocID
		
	end
	set @AutoID+=1
end

if exists(select AutoID from StorageDetail where DocID=@NewDocID)
begin
	
	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@NewDocID

	insert into StorageDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
		select @NewDocID,@BillingCode,@DocType,DocImage,DocImages,2,isnull( @TotalMoney,0),CityCode,Address,'',WareID,@UserID,GETDATE(),'',ClientID,DocID,DocCode from StorageDoc where DocID=@DocID

	set @Err+=@@error
end

--入库完成
if(@IsOver=1)
begin
	Update StorageDoc set Status=2 where  DocID=@DocID
	if(@OriginalID is not null and @OriginalID<>'')
	begin
		update Orders set PurchaseStatus=0 where OrderID=@OriginalID
	end
end
else
begin
	Update StorageDoc set Status=1 where  DocID=@DocID
end

set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end