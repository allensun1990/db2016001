﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateProductPlanQuantity')
BEGIN
	DROP  Procedure  P_UpdateProductPlanQuantity
END

GO
/***********************************************************
过程名称： P_UpdateProductPlanQuantity
功能描述： 修改大货单材料采购量
参数说明：	 
编写日期： 2016/8/18
程序作者： Allen
调试记录： exec P_UpdateProductPlanQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateProductPlanQuantity]
	@OrderID nvarchar(64),
	@AutoID int ,
	@Quantity decimal(18,4)=1 ,
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@TaskID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@TotalMoney decimal(18,4),@PurchaseStatus int

if(@TaskID<>'' and exists(select AutoID from OrderTask where TaskID=@TaskID and FinishStatus=2 and LockStatus=1 ))
begin
	rollback tran
	return
end

select @Status=OrderStatus,@PurchaseStatus=PurchaseStatus from Orders 
where OrderID=@OrderID  and (ClientID=@ClientID or EntrustClientID=@ClientID)

update OrderDetail set PlanQuantity=@Quantity,TotalMoney=Price*(@Quantity + PurchaseQuantity) where OrderID=@OrderID and AutoID=@AutoID

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

 


 

