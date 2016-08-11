Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOrderProduct')
BEGIN
	DROP  Procedure  P_DeleteOrderProduct
END

GO
/***********************************************************
过程名称： P_DeleteOrderProduct
功能描述： 更换订单材料损耗用量
参数说明：	 
编写日期： 2016/2/19
程序作者： Allen
调试记录： exec P_DeleteOrderProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteOrderProduct]
	@OrderID nvarchar(64),
	@AutoID int ,
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int=-1,@TotalMoney decimal(18,4)

select @Status=OrderStatus from Orders where OrderID=@OrderID  and (ClientID=@ClientID or EntrustClientID=@ClientID)

if(@Status>1 or @Status<0)
begin
	rollback tran
	return
end

if exists(select AutoID  from OrderDetail where OrderID=@OrderID and AutoID=@AutoID and PurchaseQuantity=0 and InQuantity=0 and UseQuantity=0)
begin
	delete from OrderDetail where OrderID=@OrderID and AutoID=@AutoID and PurchaseQuantity=0 and InQuantity=0 and UseQuantity=0

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID

	if(@TotalMoney is null)
	begin
		set @TotalMoney=0
	end

	Update Orders set Price=@TotalMoney where OrderID=@OrderID
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

 


 

