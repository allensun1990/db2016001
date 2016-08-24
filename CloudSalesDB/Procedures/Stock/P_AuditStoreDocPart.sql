Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditStoreDocPart')
BEGIN
	DROP  Procedure  P_AuditStoreDocPart
END

GO
/***********************************************************
过程名称： P_AuditStoreDocPart
功能描述： 审核未处理的入库单
参数说明：	 
编写日期： 2016/8/22
程序作者： Michaux
调试记录： exec P_AuditStoreDocPart 
************************************************************/

create proc P_AuditStoreDocPart
@DocID nvarchar(64), 
@OriginID varchar(64),
@ProductsDetails nvarchar(4000),
@IsOver int=0,
@Remark nvarchar(4000)='', 
@UserID nvarchar(64),
@OperateIP nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
as

begin tran

declare @Err int=0,@Status int,@WareID nvarchar(64),@DocType int,@DocCode varchar(64),@TotalMoney decimal(18,4),
@RealMoney decimal(18,4)=0 

select @Status=Status,@WareID=WareID,@TotalMoney=TotalMoney,@DocCode=DocCode,@DocType=DocType from StorageDoc where DocID=@OriginID
if(@Status>1 and  @Status!=3)
begin
	set @Result=2 
	set @ErrInfo='采购单已完成操作！'
	rollback tran
	return
end
--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity decimal(18,4),@BatchCode nvarchar(50),@DepotID nvarchar(64),
@sql nvarchar(4000),@GoodsQuantity nvarchar(200),@GoodsAutoID nvarchar(64),@Price decimal(18,4),@BillingCode varchar(64)

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

		if(@Quantity is null or @Quantity=0)
		begin
			set @AutoID+=1
			continue;
		end

		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Price=price,@BatchCode=BatchCode from StoragePartDetail where DocID=@DocID and AutoID=@GoodsAutoID

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
							select @ProductDetailID,@ProductID,@OriginID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),@DocType,0,@Quantity,@WareID,@DepotID,@UserID,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage
							from StorageDetail where ProductDetailID=@ProductDetailID and DocID=@OriginID

		--修改产品入库数
		update Products set StockIn=StockIn+@Quantity where ProductID=@ProductID

		--修改产品明细入库数
		update ProductDetail set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID
		set @Err+=@@Error

		--更新已入库数量
		Update StorageDetail set Complete=Complete+@Quantity,DepotID=@DepotID where ProductDetailID=@ProductDetailID and DocID=@OriginID 
		
		--更新实际入库数量
		update StoragePartDetail set Complete=@Quantity,CompleteMoney=@Quantity*@Price where DocID=@DocID and AutoID=@GoodsAutoID 
		
	end
	set @AutoID+=1
end

select @RealMoney=TotalMoney,@BillingCode=DocCode from StorageDocPart where DocID=@DocID

select @RealMoney=@RealMoney+isnull(sum(CompleteMoney),0) from StoragePartDetail where DocID=@DocID

update StorageDocPart set status=2,UpdateTime=getdate(), CreateUserID=@UserID,TotalMoney=@RealMoney where DocID=@DocID

insert into StorageDocAction(DocID,Remark,CreateTime,CreateUserID,OperateIP)
			values( @OriginID,'审核入库',getdate(),@UserID,'')
			
if(@IsOver=1)
begin 
	
	Update StorageDoc set Status=2,RealMoney=RealMoney+@RealMoney where  DocID=@OriginID

	select @TotalMoney=sum(TotalMoney) from StorageDocPart where DocID=@DocID

	insert into StorageBilling(BillingID,BillingCode,DocID,DocCode,TotalMoney,Type,Status,PayStatus,InvoiceStatus,AgentID,ClientID,CreateUserID)
		   values(NEWID(),@BillingCode,@OriginID,@DocCode,isnull(@TotalMoney,0),1,1,0,0,@AgentID,@ClientID,@UserID)
end
else
begin
	Update StorageDoc set Status=1,RealMoney=RealMoney+@RealMoney where  DocID=@OriginID
end


set @Err+=@@Error

if(@Err>0)
begin
	set @Result=1 
	set @ErrInfo='程序错误，请联系管理员！'
	rollback tran
end 
else
begin
	commit tran
end