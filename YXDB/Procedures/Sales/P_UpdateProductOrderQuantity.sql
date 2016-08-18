Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateProductOrderQuantity')
BEGIN
	DROP  Procedure  P_UpdateProductOrderQuantity
END

GO
/***********************************************************
过程名称： P_UpdateProductOrderQuantity
功能描述： 更换订单材料下单量
参数说明：	 
编写日期： 2016/2/19
程序作者： Allen
调试记录： exec P_UpdateProductOrderQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateProductOrderQuantity]
	@OrderID nvarchar(64),
	@AutoID int ,
	@Quantity int=1 ,
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@TotalMoney decimal(18,4),@PurchaseStatus int

select @Status=OrderStatus,@PurchaseStatus=PurchaseStatus from Orders 
where OrderID=@OrderID  and (ClientID=@ClientID or EntrustClientID=@ClientID)

update OrderDetail set OrderQuantity=@Quantity,PlanQuantity=@Quantity*Quantity,TotalMoney=Price*(@Quantity*Quantity + PurchaseQuantity) where OrderID=@OrderID and AutoID=@AutoID

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

 


 

