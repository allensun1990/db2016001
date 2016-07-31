Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InvalidApplyReturnProduct')
BEGIN
	DROP  Procedure  P_InvalidApplyReturnProduct
END

GO
/***********************************************************
过程名称： P_InvalidApplyReturnProduct
功能描述： 驳回退货申请
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_InvalidApplyReturnProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_InvalidApplyReturnProduct]
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


if(@ReturnStatus<>1)
begin
	set @Result=2 
	set @ErrInfo='退货申请已处理，不能重复操作！'
	rollback tran
	return
end

update Orders set ReturnStatus=0 where OrderID=@OldOrderID
Update OrderGoods set ApplyQuantity=0 where OrderID=@OldOrderID


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