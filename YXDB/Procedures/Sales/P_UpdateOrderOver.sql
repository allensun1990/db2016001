Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderOver')
BEGIN
	DROP  Procedure  P_UpdateOrderOver
END

GO
/***********************************************************
过程名称： P_UpdateOrderOver
功能描述： 终止订单
参数说明：	 
编写日期： 2016/3/29
程序作者： Allen
调试记录： exec P_UpdateOrderOver 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderOver]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@AliOrderCode nvarchar(64),@OrderType int,@CustomerID nvarchar(64),@GoodsID nvarchar(64)

select @Status=OrderStatus,@AliOrderCode=AliOrderCode,@OrderType=OrderType,@CustomerID=CustomerID,@GoodsID=GoodsID 
from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

if(@Status <> 1)
begin
	rollback tran
	return
end


Update Orders set OrderStatus=8 where OrderID=@OrderID

Update OrderTask set Status=8 where OrderID=@OrderID

Update Goods set Status=8 where GoodsID=@GoodsID

set @Err+=@@error

if(@AliOrderCode is not null and @AliOrderCode<>'')
begin
	insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,ClientID)
	values(NEWID(),@OrderID,@AliOrderCode,@OrderType,0,9,0,0,getdate(),getdate(),'',@ClientID)
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

 


 

