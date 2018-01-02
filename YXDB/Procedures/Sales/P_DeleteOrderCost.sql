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
	@ClientID nvarchar(64)=''
AS
	
begin tran

if exists(select AutoID from OrderCosts where OrderID=@OrderID and AutoID=@AutoID and Quantity>0)
begin
	rollback tran
	return
end

declare @Err int=0,@Money decimal(18,4)

Update OrderCosts set Status=9 where OrderID=@OrderID and AutoID=@AutoID and Quantity=0

select @Money=sum(Price) from  OrderCosts where OrderID=@OrderID and Status=1

Update Orders set CostPrice=isnull(@Money,0) where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

