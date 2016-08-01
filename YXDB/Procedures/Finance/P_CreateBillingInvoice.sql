Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateBillingInvoice')
BEGIN
	DROP  Procedure  P_CreateBillingInvoice
END

GO
/***********************************************************
过程名称： P_CreateBillingInvoice
功能描述： 添加开票
参数说明：	 
编写日期： 2015/11/18
程序作者： Allen
调试记录： exec P_CreateBillingInvoice 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateBillingInvoice]
	@InvoiceID nvarchar(64),
	@BillingID nvarchar(64),
	@Type int,
	@CustomerType int,
	@InvoiceMoney decimal(18,4),
	@InvoiceTitle nvarchar(50)='',
	@CityCode  nvarchar(50)='',
	@Address  nvarchar(50)='',
	@PostalCode  nvarchar(50)='',
	@ContactName  nvarchar(50)='',
	@ContactPhone  nvarchar(50)='',
	@Remark nvarchar(4000)='',
	@UserID nvarchar(64),
	@ClientID nvarchar(64)
AS


begin tran

	declare @Err int=0

	if exists (select AutoID from BillingInvoice where BillingID=@BillingID and Status<>9 )
	begin
		rollback tran
		return
	end

	insert into BillingInvoice(InvoiceID,BillingID,Type,CustomerType,Status,InvoiceTitle,InvoiceMoney,CityCode,Address,PostalCode,ContactName,ContactPhone,Remark,CreateTime,CreateUserID,ClientID)
			values(@InvoiceID,@BillingID,@Type,@CustomerType,0,@InvoiceTitle,@InvoiceMoney,@CityCode,@Address,@PostalCode,@ContactName,@ContactPhone,@Remark,getdate(),@UserID,@ClientID)
	set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end