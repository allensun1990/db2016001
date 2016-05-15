Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateStorageBillingInvoice')
BEGIN
	DROP  Procedure  P_CreateStorageBillingInvoice
END

GO
/***********************************************************
过程名称： P_CreateStorageBillingInvoice
功能描述： 添加开票
参数说明：	 
编写日期： 2015/11/18
程序作者： Allen
调试记录： exec P_CreateStorageBillingInvoice 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateStorageBillingInvoice]
	@InvoiceID nvarchar(64),
	@BillingID nvarchar(64),
	@Type int,
	@InvoiceMoney decimal(18,4),
	@InvoiceCode nvarchar(50)='',
	@Remark nvarchar(4000)='',
	@UserID nvarchar(64),
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
begin tran

	declare @Err int=0

	declare @TotalMoney decimal(18,4),@TotalInvoiceMoney decimal(18,4)

	insert into StorageBillingInvoice(InvoiceID,BillingID,Type,Status,InvoiceCode,InvoiceMoney,Remark,CreateTime,CreateUserID,AgentID,ClientID)
			values(@InvoiceID,@BillingID,@Type,1,@InvoiceCode,@InvoiceMoney,@Remark,getdate(),@UserID,@AgentID,@ClientID)
	set @Err+=@@error

	select @TotalMoney=TotalMoney,@TotalInvoiceMoney=InvoiceMoney from StorageBilling where BillingID=@BillingID

	if(@TotalInvoiceMoney+@InvoiceMoney>=@TotalMoney)
	begin
		update StorageBilling set InvoiceMoney=InvoiceMoney+@InvoiceMoney,InvoiceStatus=2,InvoiceTime=getdate() where  BillingID=@BillingID
	end
	else if(@TotalInvoiceMoney+@InvoiceMoney>0)
	begin
		update StorageBilling set InvoiceMoney=InvoiceMoney+@InvoiceMoney,InvoiceStatus=1,InvoiceTime=getdate() where  BillingID=@BillingID
	end
	else
	begin
		update StorageBilling set InvoiceMoney=InvoiceMoney+@InvoiceMoney,InvoiceStatus=0,InvoiceTime=getdate() where  BillingID=@BillingID
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