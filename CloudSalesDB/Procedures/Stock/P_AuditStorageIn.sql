Use [CloudSales1.0_dev]
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
		insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage)
							select @ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),@DocType,0,@Quantity,@WareID,@DepotID,@UserID,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage
							from StorageDetail where AutoID=@GoodsAutoID and DocID=@DocID

		--修改产品入库数
		update Products set StockIn=StockIn+@Quantity where ProductID=@ProductID

		--修改产品明细入库数
		update ProductDetail set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID
		set @Err+=@@Error

		--更新已入库数量
		Update StorageDetail set Complete=Complete+@Quantity,DepotID=@DepotID where  AutoID=@GoodsAutoID and DocID=@DocID

		insert into StoragePartDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage )
			select @NewDocID,ProductDetailID,ProductID,UnitID,0,@Quantity,Price,Price*@Quantity,WareID,@DepotID,BatchCode,0,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage 
			from StorageDetail where AutoID=@GoodsAutoID and DocID=@DocID
		
	end
	set @AutoID+=1
end

if exists(select AutoID from StoragePartDetail where DocID=@NewDocID)
begin
	
	select @TotalMoney=sum(TotalMoney) from StoragePartDetail where DocID=@NewDocID

	insert into StorageDocPart(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
		select @NewDocID,@BillingCode,1,2,@TotalMoney,CityCode,Address,'',WareID,@UserID,GETDATE(),'',ClientID,DocID,DocCode from StorageDoc where DocID=@DocID

	insert into StorageDocAction(DocID,Remark,CreateTime,CreateUserID,OperateIP)
			values( @DocID,'审核入库',getdate(),@UserID,'')

	set @Err+=@@error
end

if(@IsOver=1)
begin
	Update StorageDoc set Status=2 where  DocID=@DocID

	select @TotalMoney=sum(TotalMoney) from StorageDocPart where OriginalID=@DocID

	insert into StorageBilling(BillingID,BillingCode,DocID,DocCode,TotalMoney,Type,Status,PayStatus,InvoiceStatus,AgentID,ClientID,CreateUserID)
		   values(NEWID(),@BillingCode,@DocID,@DocCode,@TotalMoney,1,1,0,0,@AgentID,@ClientID,@UserID)
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