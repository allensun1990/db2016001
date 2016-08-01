Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateBillingPay')
BEGIN
	DROP  Procedure  P_CreateBillingPay
END

GO
/***********************************************************
过程名称： P_CreateBillingPay
功能描述： 添加收款
参数说明：	 
编写日期： 2016/3/28
程序作者： Allen
调试记录： exec P_CreateBillingPay 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateBillingPay]
	@BillingID nvarchar(64),
	@Type int,
	@PayType int,
	@PayMoney decimal(18,4),
	@PayTime datetime,
	@Remark nvarchar(4000),
	@UserID nvarchar(64),
	@ClientID nvarchar(64)
AS
begin tran

	declare @Err int=0

	insert into BillingPay(BillingID,Type,Status,PayType,PayTime,PayMoney,Remark,CreateTime,CreateUserID,ClientID)
			values(@BillingID,@Type,1,@PayType,@PayTime,@PayMoney,@Remark,getdate(),@UserID,@ClientID)
	set @Err+=@@error


	--收款
	if(@Type=2)
	begin
		update Orders set PayMoney=PayMoney+@PayMoney where  OrderID=@BillingID

		set @Err+=@@error
	end
	else 
	begin
		update Orders set ReturnMoney=ReturnMoney+@PayMoney where  OrderID=@BillingID

	end
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end