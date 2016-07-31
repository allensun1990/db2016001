Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteStorageBillingInvoice')
BEGIN
	DROP  Procedure  P_DeleteStorageBillingInvoice
END

GO
/***********************************************************
过程名称： P_DeleteStorageBillingInvoice
功能描述： 删除开票
参数说明：	 
编写日期： 2015/11/18
程序作者： Allen
调试记录： exec P_DeleteStorageBillingInvoice 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteStorageBillingInvoice]
	@InvoiceID nvarchar(64),
	@BillingID nvarchar(64),
	@UserID nvarchar(64),
	@ClientID nvarchar(64)
AS
begin tran

	declare @Err int=0

	declare @TotalMoney decimal(18,4),@TotalInvoiceMoney decimal(18,4)

	Update StorageBillingInvoice set Status=9 where InvoiceID=@InvoiceID
	
	set @Err+=@@error

	select @TotalInvoiceMoney=sum(InvoiceMoney) from StorageBillingInvoice where BillingID=@BillingID and Status=1

	select @TotalMoney=TotalMoney from StorageBilling where BillingID=@BillingID

	if(@TotalInvoiceMoney>=@TotalMoney)
	begin
		update StorageBilling set InvoiceMoney=@TotalInvoiceMoney,InvoiceStatus=2,InvoiceTime=getdate() where  BillingID=@BillingID
	end
	else if(@TotalInvoiceMoney>0)
	begin
		update StorageBilling set InvoiceMoney=@TotalInvoiceMoney,InvoiceStatus=1,InvoiceTime=getdate() where  BillingID=@BillingID
	end
	else
	begin
		update StorageBilling set InvoiceMoney=0,InvoiceStatus=0,InvoiceTime=getdate() where  BillingID=@BillingID
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