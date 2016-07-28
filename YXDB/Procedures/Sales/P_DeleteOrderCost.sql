Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOrderCost')
BEGIN
	DROP  Procedure  P_DeleteOrderCost
END

GO
/***********************************************************
过程名称： P_DeleteOrderCost
功能描述： 添加其他成本
参数说明：	 
编写日期： 2016/3/20
程序作者： Allen
调试记录： exec P_DeleteOrderCost 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteOrderCost]
	@OrderID nvarchar(64),
	@AutoID int,
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Money decimal(18,4)

Update OrderCosts set Status=9 where OrderID=@OrderID and AutoID=@AutoID

select @Money=sum(Price) from  OrderCosts where OrderID=@OrderID and Status=1

Update Orders set CostPrice=isnull(@Money,0) where OrderID=@OrderID

update Orders set CostPrice=isnull(@Money,0) where OriginalID=@OrderID and OrderStatus=1

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

