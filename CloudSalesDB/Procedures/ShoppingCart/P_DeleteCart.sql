Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteCart')
BEGIN
	DROP  Procedure  P_DeleteCart
END

GO
/***********************************************************
过程名称： P_DeleteCart
功能描述： 删除购物车产品
参数说明：	 
编写日期： 2015/12/6
程序作者： Allen
调试记录： exec P_DeleteCart 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteCart]
@ProductID nvarchar(64)='',
@OrderType int,
@GUID nvarchar(64)='',
@UserID nvarchar(64),
@DepotID nvarchar(64)=''
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0

if(@OrderType=10) --机会
begin
	if not exists(select AutoID from Opportunity where  OpportunityID=@GUID and Status=1)
	begin
		rollback tran
		return
	end
	delete from OpportunityProduct where OpportunityID=@GUID and ProductDetailID=@ProductID

	select @TotalMoney=sum(TotalMoney) from OpportunityProduct where OpportunityID=@GUID

	update Opportunity set TotalMoney=isnull(@TotalMoney,0) where OpportunityID=@GUID
end
else if(@OrderType=11) --订单
begin
	if not exists(select AutoID from Orders where  OrderID=@GUID and Status=1)
	begin
		rollback tran
		return
	end
	delete from OrderDetail where OrderID=@GUID and ProductDetailID=@ProductID

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@GUID

	update Orders set TotalMoney=isnull(@TotalMoney,0) where OrderID=@GUID
end
else if(@DepotID<>'')
begin
	delete from ShoppingCart where [GUID]=@GUID and ProductDetailID=@ProductID and UserID=@UserID and DepotID=@DepotID
end
else
begin
	delete from ShoppingCart where [GUID]=@GUID and ProductDetailID=@ProductID and UserID=@UserID
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