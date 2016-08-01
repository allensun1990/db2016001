Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrderCost')
BEGIN
	DROP  Procedure  P_CreateOrderCost
END

GO
/***********************************************************
过程名称： P_CreateOrderCost
功能描述： 添加其他成本
参数说明：	 
编写日期： 2016/3/20
程序作者： Allen
调试记录： exec P_CreateOrderCost 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrderCost]
	@OrderID nvarchar(64),
	@Price decimal(18,4)=0 ,
	@Remark nvarchar(4000),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Money decimal(18,4)

insert into OrderCosts(OrderID,Price,Remark,Status,CreateUserID,ClientID)
values(@OrderID,@Price,@Remark,1,@OperateID,@ClientID)

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

 


 

