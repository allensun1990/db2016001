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
	@ClientID nvarchar(64)='',
	@TaskID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int=-1,@TotalMoney decimal(18,4),@OrderType int,@OrderAttrID nvarchar(64),@AvgPrice decimal(18,4)

if(@TaskID<>'' and exists(select AutoID from OrderTask where TaskID=@TaskID and FinishStatus=2 and LockStatus=1 ))
begin
	rollback tran
	return
end

select @Status=OrderStatus,@OrderType=OrderType from Orders where OrderID=@OrderID  and (ClientID=@ClientID or EntrustClientID=@ClientID)

if @OrderType=1 or exists(select AutoID  from OrderDetail where OrderID=@OrderID and AutoID=@AutoID and PurchaseQuantity=0 and InQuantity=0 and UseQuantity=0)
begin
	if(@OrderType=1) --打样单
	begin
		select @OrderAttrID=OrderAttrID from OrderDetail where OrderID=@OrderID and AutoID=@AutoID

		delete from OrderDetail where OrderID=@OrderID and AutoID=@AutoID and PurchaseQuantity=0 and InQuantity=0 and UseQuantity=0

		select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID and OrderAttrID=@OrderAttrID

		update OrderAttrs set Price=isnull(@TotalMoney,0) where OrderAttrID=@OrderAttrID 

		select @AvgPrice=avg(Price) from OrderAttrs where OrderID=@OrderID and Price>0

		update Orders set Price=isnull(@AvgPrice,0) where OrderID=@OrderID

	end
	else
	begin
		delete from OrderDetail where OrderID=@OrderID and AutoID=@AutoID and PurchaseQuantity=0 and InQuantity=0 and UseQuantity=0

		select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID

		Update Orders set Price=isnull(@TotalMoney,0) where OrderID=@OrderID
	end
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

 


 

