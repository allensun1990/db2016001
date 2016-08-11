Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderPrice')
BEGIN
	DROP  Procedure  P_UpdateOrderPrice
END

GO
/***********************************************************
过程名称： P_UpdateOrderPrice
功能描述： 更换订单产品单价
参数说明：	 
编写日期： 2015/11/15
程序作者： Allen
调试记录： exec P_UpdateOrderPrice 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderPrice]
	@OrderID nvarchar(64),
	@AutoID int ,
	@Price decimal(18,4)=0 ,
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@TotalMoney decimal(18,4),@PurchaseStatus int, @OrderType int


select @Status=OrderStatus,@PurchaseStatus=PurchaseStatus,@OrderType=@OrderType from Orders where OrderID=@OrderID 


if(@Status<>1)
begin
	rollback tran
	return
end

update OrderDetail set Price=@Price,TotalMoney=@Price*(Quantity+PurchaseQuantity) where OrderID=@OrderID and AutoID=@AutoID

select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID

Update Orders set Price=@TotalMoney where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

