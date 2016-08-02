Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ConfirmAgentOrderSend')
BEGIN
	DROP  Procedure  P_ConfirmAgentOrderSend
END

GO
/***********************************************************
过程名称： P_ConfirmAgentOrderSend
功能描述： 订单发货
参数说明：	 
编写日期： 2015/11/23
程序作者： Allen
调试记录： exec P_ConfirmAgentOrderSend 
************************************************************/
CREATE PROCEDURE [dbo].[P_ConfirmAgentOrderSend]
@OrderID nvarchar(64),
@ExpressID nvarchar(64)='',
@ExpressCode nvarchar(100)='',
@UserID nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64), 
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @OrderStatus int,@OrderSendStatus int,@OldOrderID nvarchar(64),@ReturnStatus int,@CustomerID varchar(50),@DocID nvarchar(64),@Err int=0,@TotalFee decimal(18,4),@InterFeeRate decimal(18,4)

select @OrderStatus=Status,@OrderSendStatus=SendStatus,@OldOrderID=OriginalID,@ReturnStatus=ReturnStatus,@DocID=DocID,@CustomerID=CustomerID,@TotalFee=TotalMoney  from AgentsOrders where OrderID=@OrderID


if(@OrderSendStatus=0)
begin
	set @Result=2 
	set @ErrInfo='订单未出库!'
	rollback tran
	return
end
if(@OrderSendStatus>1 and @OrderStatus=2)
begin
	set @Result=2 
	set @ErrInfo='订单已发货!'
	rollback tran
	return
end
if(@ReturnStatus>0 or @OrderStatus=3)
begin
	set @Result=3 --订单已退单
	set @ErrInfo='订单已退单!'
	rollback tran
	return
end


Update AgentsOrders set SendStatus=2,ExpressID=@ExpressID,ExpressCode=@ExpressCode where OrderID=@OrderID

update Orders set SendStatus=2,ExpressID=@ExpressID,ExpressCode=@ExpressCode where OrderID=@OldOrderID
 

set @Err+=@@Error

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