Use [CloudSales1.0_dev]
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
编写日期： 2015/11/19
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
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
begin tran

	declare @Err int=0

	declare @TotalMoney decimal(18,4),@TotalPayMoney decimal(18,4),@OrderID nvarchar(64),@BillingCode nvarchar(50),@ReturnMoney decimal(18,4)

	select @TotalMoney=TotalMoney,@TotalPayMoney=PayMoney,@OrderID=OrderID,@BillingCode=BillingCode,@AgentID=AgentID,@ReturnMoney=ReturnMoney from Billing where BillingID=@BillingID

	insert into BillingPay(BillingID,Type,Status,PayType,PayTime,PayMoney,Remark,CreateTime,CreateUserID,AgentID,ClientID)
			values(@BillingID,@Type,1,@PayType,@PayTime,@PayMoney,@Remark,getdate(),@UserID,@AgentID,@ClientID)
	set @Err+=@@error

	declare @levelMoney decimal(18,4),@DefaultAgentID nvarchar(64)
	select @levelMoney=TotalIn-TotalOut,@DefaultAgentID=AgentID from Clients where ClientID=@ClientID

	--收款
	if(@Type=2)
	begin
		if(@TotalPayMoney+@PayMoney>=@TotalMoney)
		begin
			update Billing set PayMoney=PayMoney+@PayMoney,PayStatus=2,PayTime=getdate() where  BillingID=@BillingID
		end
		else if(@TotalPayMoney+@PayMoney>0)
		begin
			update Billing set PayMoney=PayMoney+@PayMoney,PayStatus=1,PayTime=getdate() where  BillingID=@BillingID
		end
		else
		begin
			update Billing set PayMoney=PayMoney+@PayMoney,PayStatus=0,PayTime=getdate() where  BillingID=@BillingID
		end
		set @Err+=@@error

		--公司账户处理
		if(@DefaultAgentID=@AgentID)
		begin

			update Clients set TotalIn=TotalIn+@PayMoney where ClientID=@ClientID
			set @Err+=@@error

			insert into ClientAccounts(AgentID,HappenMoney,EndMoney,Mark,SubjectID,Remark,CreateUserID,ClientID)
			values(@AgentID,@PayMoney,@levelMoney+@PayMoney,0,2,'销售账单收款，账单编号：'+@BillingCode,@UserID,@ClientID)
			set @Err+=@@error
		
		end
	end
	else 
	begin
		if(@ReturnMoney+@PayMoney>=@TotalMoney)
		begin
			update Billing set ReturnMoney=ReturnMoney+@PayMoney,ReturnStatus=2 where  BillingID=@BillingID
		end
		else if(@ReturnMoney+@PayMoney>0)
		begin
			update Billing set ReturnMoney=ReturnMoney+@PayMoney,ReturnStatus=1 where  BillingID=@BillingID
		end
		else
		begin
			update Billing set ReturnMoney=ReturnMoney+@PayMoney,ReturnStatus=0 where  BillingID=@BillingID
		end
		set @Err+=@@error

		--公司账户处理
		if(@DefaultAgentID=@AgentID)
		begin

			update Clients set TotalOut=TotalOut+@PayMoney where ClientID=@ClientID
			set @Err+=@@error

			insert into ClientAccounts(AgentID,HappenMoney,EndMoney,Mark,SubjectID,Remark,CreateUserID,ClientID)
			values(@AgentID,@PayMoney,@levelMoney-@PayMoney,1,3,'销售账单退款，账单编号：'+@BillingCode,@UserID,@ClientID)
			set @Err+=@@error
		
		end
	end
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end