Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderProductQuantity')
BEGIN
	DROP  Procedure  P_UpdateOrderProductQuantity
END

GO
/***********************************************************
过程名称： P_UpdateOrderProductQuantity
功能描述： 更换订单材料用量
参数说明：	 
编写日期： 2016/2/19
程序作者： Allen
调试记录： exec P_UpdateOrderProductQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderProductQuantity]
	@OrderID nvarchar(64),
	@AutoID int ,
	@Quantity decimal(18,4)=1 ,
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@TotalMoney decimal(18,4),@PurchaseStatus int

select @Status=OrderStatus,@PurchaseStatus=PurchaseStatus from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status<>1 or @PurchaseStatus=1)
begin
	rollback tran
	return
end

update OrderDetail set Quantity=@Quantity,TotalMoney=Price*(@Quantity+Loss),LossRate=Loss/@Quantity where OrderID=@OrderID and AutoID=@AutoID

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

 


 

