Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOrder')
BEGIN
	DROP  Procedure  P_DeleteOrder
END

GO
/***********************************************************
过程名称： P_DeleteOrder
功能描述： 删除订单
参数说明：	 
编写日期： 2015/11/15
程序作者： Allen
调试记录： exec P_DeleteOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteOrder]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@AliOrderCode nvarchar(64),@OrderType int,@CustomerID nvarchar(64)

select @Status=Status,@AliOrderCode=AliOrderCode,@OrderType=OrderType,@CustomerID=CustomerID from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status <> 0)
begin
	rollback tran
	return
end


Update Orders set Status=9,OrderStatus=9 where OrderID=@OrderID

--处理客户需求单数
Update Customer set DemandCount=DemandCount-1 where CustomerID=@CustomerID and DemandCount>0

if(@AliOrderCode is not null and @AliOrderCode<>'')
begin
	insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,AgentID,ClientID)
	values(NEWID(),@OrderID,@AliOrderCode,@OrderType,0,9,0,0,getdate(),getdate(),'',@ClientID,@ClientID)
	set @Err+=@@error
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

 


 

