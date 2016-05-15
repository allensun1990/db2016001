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
@AutoID int,
@BillingCode nvarchar(50),
@UserID nvarchar(64),
@OperateIP nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)
AS

begin tran

declare @Err int,@DetailID nvarchar(64),@BatchCode nvarchar(50),@WareID nvarchar(64),@DepotID nvarchar(64),@ProductID nvarchar(64),@Quantity int,@IsBig int,
		@DocID nvarchar(64),@DocCode nvarchar(20),@Desc nvarchar(500),@TotalMoney decimal(18,4)
set @Err=0

if exists(select AutoID from StorageDetail where AutoID=@AutoID and Status=1)
begin
	rollback tran
	return
end

select @ProductID=ProductID,@DetailID=ProductDetailID,@BatchCode=BatchCode,@WareID=WareID,@DepotID=DepotID,@Quantity=Quantity,@IsBig=IsBigUnit ,@DocID=DocID,@Desc=Remark
from StorageDetail where AutoID=@AutoID 

select @DocCode=DocCode,@TotalMoney=TotalMoney from StorageDoc where DocID=@DocID

--大单位
if(@IsBig=1)
begin
	select @Quantity=BigSmallMultiple*@Quantity from Products where ProductID=@ProductID
	set @Err+=@@Error
end

--处理库存
if exists(select AutoID from ProductStock where ProductDetailID=@DetailID and WareID=@WareID and DepotID=@DepotID and BatchCode=@BatchCode)
begin
	update ProductStock set StockIn=StockIn+@Quantity where ProductDetailID=@DetailID and WareID=@WareID and DepotID=@DepotID and BatchCode=@BatchCode
end
else
begin
	insert into ProductStock(ProductDetailID,ProductID,StockIn,StockOut,BatchCode,WareID,DepotID,ClientID)
						values (@DetailID,@ProductID,@Quantity,0,@BatchCode,@WareID,@DepotID,@ClientID)
end
set @Err+=@@Error

--处理产品流水
insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
					values(@DetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),1,0,@Quantity,@WareID,@DepotID,@UserID,@ClientID)

--修改单据明细状态
update StorageDetail set Status=1 where  AutoID=@AutoID 
set @Err+=@@Error

--修改产品入库数
update Products set StockIn=StockIn+@Quantity where ProductID=@ProductID

--修改产品明细入库数
update ProductDetail set StockIn=StockIn+@Quantity where ProductDetailID=@DetailID

--记录审核日志
insert into StorageDocAction(DocID,Remark,CreateTime,CreateUserID,OperateIP)
						select @DocID,'审核 '+ProductName+' '+ @Desc+ ' 上架',getdate(),@UserID,@OperateIP from Products where  ProductID=@ProductID

--修改单据状态
if exists(select AutoID from StorageDetail where DocID=@DocID and Status=0)
begin
	Update StorageDoc set Status=1 where DocID=@DocID
end
else 
begin
	Update StorageDoc set Status=2 where DocID=@DocID
	--全部上架生成账单
	insert into StorageBilling(BillingID,BillingCode,DocID,DocCode,TotalMoney,Type,Status,PayStatus,InvoiceStatus,AgentID,ClientID,CreateUserID)
						values(NEWID(),@BillingCode,@DocID,@DocCode,@TotalMoney,1,1,0,0,@AgentID,@ClientID,@UserID)
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