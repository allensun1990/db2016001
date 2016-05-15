Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InvalidApplyReturn')
BEGIN
	DROP  Procedure  P_InvalidApplyReturn
END

GO
/***********************************************************
过程名称： P_InvalidApplyReturn
功能描述： 驳回退单申请
参数说明：	 
编写日期： 2015/11/23
程序作者： Allen
调试记录： exec P_InvalidApplyReturn 
************************************************************/
CREATE PROCEDURE [dbo].[P_InvalidApplyReturn]
@OrderID nvarchar(64),
@UserID nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @OrderStatus int,@OrderSendStatus int,@OldOrderID nvarchar(64),@ReturnStatus int,@Err int=0

select @OrderStatus=Status,@OrderSendStatus=SendStatus,@OldOrderID=OriginalID,@ReturnStatus=ReturnStatus  from AgentsOrders where OrderID=@OrderID


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

Update AgentsOrders set ReturnStatus=0 where OrderID=@OrderID

update Orders set ReturnStatus=0 where OrderID=@OldOrderID

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