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
	@ClientID nvarchar(64)='',
	@TaskID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@TotalMoney decimal(18,4),@PurchaseStatus int,@OrderType int,@OrderAttrID nvarchar(64),@AvgPrice decimal(18,4)

if(@TaskID<>'' and exists(select AutoID from OrderTask where TaskID=@TaskID and FinishStatus=2 and LockStatus=1 ))
begin
	rollback tran
	return
end

select @Status=OrderStatus,@PurchaseStatus=PurchaseStatus,@OrderType=OrderType from Orders 
where OrderID=@OrderID  and (ClientID=@ClientID or EntrustClientID=@ClientID)

if(@OrderType=1)
begin
	select @OrderAttrID=OrderAttrID from OrderDetail where OrderID=@OrderID and AutoID=@AutoID

	update OrderDetail set Quantity=@Quantity,TotalMoney=Price*@Quantity where OrderID=@OrderID and AutoID=@AutoID

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID and OrderAttrID=@OrderAttrID

	update OrderAttrs set Price=isnull(@TotalMoney,0) where OrderAttrID=@OrderAttrID 

	select @AvgPrice=avg(Price) from OrderAttrs where OrderID=@OrderID and Price>0

	update Orders set Price=isnull(@AvgPrice,0) where OrderID=@OrderID
end
else
begin
	update OrderDetail set Quantity=@Quantity,PlanQuantity=@Quantity*OrderQuantity,TotalMoney=Price*(@Quantity*OrderQuantity + PurchaseQuantity) where OrderID=@OrderID and AutoID=@AutoID

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID

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

 


 

