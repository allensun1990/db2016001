Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditApplyReturn')
BEGIN
	DROP  Procedure  P_AuditApplyReturn
END

GO
/***********************************************************
过程名称： P_AuditApplyReturn
功能描述： 审核退单申请
参数说明：	 
编写日期： 2015/11/23
程序作者： Allen
调试记录： exec P_AuditApplyReturn 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditApplyReturn]
@OrderID nvarchar(64),
@UserID nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@OrderStatus int,@OrderSendStatus int,@OldOrderID nvarchar(64),@ReturnStatus int,@TotalMoney decimal(18,4),@OrderAgentID nvarchar(64),
		@OrderCode nvarchar(50)

select @OrderStatus=Status,@OrderSendStatus=SendStatus,@OldOrderID=OriginalID,@ReturnStatus=ReturnStatus,@TotalMoney=TotalMoney,@OrderAgentID=AgentID,@OrderCode=OrderCode  
from AgentsOrders where OrderID=@OrderID

if(@ReturnStatus=0)
begin
	set @Result=2 
	set @ErrInfo='退单申请已取消！'
	rollback tran
	return
end
if(@OrderSendStatus>0)
begin
	set @Result=2 
	set @ErrInfo='订单已出库!'
	rollback tran
	return
end
if(@OrderStatus=3)
begin
	set @Result=3 --订单已退单
	set @ErrInfo='订单申请已审核!'
	rollback tran
	return
end

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int


select identity(int,1,1) as AutoID,ProductID,ProductDetailID,Quantity into #TempProducts 
from AgentsOrderDetail where OrderID=@OrderID

--代理商信息
declare @IsDefault int,@levelMoney decimal(18,4)
select @IsDefault=IsDefault,@levelMoney=TotalIn-TotalOut from Agents where AgentID=@OrderAgentID

if(@IsDefault=1)
begin
	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
	
		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity from #TempProducts where AutoID=@AutoID

		insert into AgentsStream(ProductDetailID,ProductID,OrderID,OrderCode,OrderDate,Mark,Quantity,SurplusQuantity,AgentID,ClientID)
							values(@ProductDetailID,@ProductID,@OrderID,@OrderCode,CONVERT(varchar(100), GETDATE(), 112),1,@Quantity,0,@OrderAgentID,@ClientID)

		insert into AgentsStream(ProductDetailID,ProductID,OrderID,OrderCode,OrderDate,Mark,Quantity,SurplusQuantity,AgentID,ClientID)
							values(@ProductDetailID,@ProductID,@OldOrderID,@OrderCode,CONVERT(varchar(100), GETDATE(), 112),0,@Quantity,0,@OrderAgentID,@ClientID)
		set @Err+=@@Error

		Update AgentsStock set TotalInWay=TotalInWay-@Quantity,TotalOut=TotalOut-@Quantity  where ProductDetailID=@ProductDetailID and AgentID=@OrderAgentID

		update Products set LogicOut=LogicOut-@Quantity where ProductID=@ProductID

		update ProductDetail set LogicOut=LogicOut-@Quantity where ProductDetailID=@ProductDetailID

		set @Err+=@@Error

		set @AutoID=@AutoID+1
	end

	update Agents set TotalOut=TotalOut-@TotalMoney where AgentID=@OrderAgentID

	--代理商账户处理
	insert into AgentsAccounts(AgentID,HappenMoney,EndMoney,Mark,SubjectID,Remark,CreateUserID,ClientID)
	values(@OrderAgentID,@TotalMoney,@levelMoney+@TotalMoney,0,3,'采购订单退单，订单号：'+@OrderCode,@UserID,@ClientID)
	set @Err+=@@Error

	--销售订单状态
	update Orders set ReturnStatus=3,Status=3 where OrderID=@OldOrderID

	set @Err+=@@Error
end

--代理商订单
Update AgentsOrders set ReturnStatus=3,Status=3 where OrderID=@OrderID

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end