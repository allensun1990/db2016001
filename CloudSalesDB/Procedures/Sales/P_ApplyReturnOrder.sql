Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ApplyReturnOrder')
BEGIN
	DROP  Procedure  P_ApplyReturnOrder
END

GO
/***********************************************************
过程名称： P_ApplyReturnOrder
功能描述： 申请退单
参数说明：	 
编写日期： 2015/11/24
程序作者： Allen
调试记录： exec P_ApplyReturnOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_ApplyReturnOrder]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS
	
begin tran

set @Result=0

--订单信息
declare @Err int=0,@Status int,@OrderAgentID nvarchar(64),@SendStatus nvarchar(64),@ReturnStatus nvarchar(64)
select @Status=Status,@OrderAgentID=AgentID,@SendStatus=SendStatus,@ReturnStatus=ReturnStatus from Orders where OrderID=@OrderID and ClientID=@ClientID

if(@Status<>2)
begin
	rollback tran
	return
end

if(@SendStatus>0 )
begin
	rollback tran
	return
end
if(@ReturnStatus<>0)
begin
	rollback tran
	return
end

update Orders set ReturnStatus=1 where OrderID=@OrderID
set @Err+=@@error

update AgentsOrders set ReturnStatus=1 where OriginalID=@OrderID
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 

