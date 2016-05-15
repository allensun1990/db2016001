Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditBillingInvoice')
BEGIN
	DROP  Procedure  P_AuditBillingInvoice
END

GO
/***********************************************************
过程名称： P_AuditBillingInvoice
功能描述： 审核开票
参数说明：	 
编写日期： 2015/11/18
程序作者： Allen
调试记录： exec P_AuditBillingInvoice 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditBillingInvoice]
	@InvoiceID nvarchar(64),
	@BillingID nvarchar(64),
	@InvoiceMoney decimal(18,4),
	@InvoiceCode nvarchar(64),
	@ExpressID nvarchar(64),
	@ExpressCode nvarchar(64),
	@UserID nvarchar(64),
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
begin tran

	declare @Err int=0

	declare @Status int
	select @Status=Status from BillingInvoice where InvoiceID=@InvoiceID

	if(@Status<>0)
	begin
		rollback tran
		return
	end

	Update BillingInvoice set Status=1,InvoiceMoney=@InvoiceMoney,InvoiceCode=@InvoiceCode,ExpressID=@ExpressID,ExpressCode=@ExpressCode,ExpressStatus=1,ExpressTime=getdate(),UpdateTime=getdate(),UpdateUserID=@UserID where InvoiceID=@InvoiceID

	update Billing set InvoiceStatus=2,InvoiceTime=getdate(),InvoiceMoney=@InvoiceMoney where  BillingID=@BillingID
	set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end