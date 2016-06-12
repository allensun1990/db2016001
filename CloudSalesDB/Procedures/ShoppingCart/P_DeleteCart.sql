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
@GUID nvarchar(64)=''
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0

if(@OrderType=10 and exists(select AutoID from Opportunity where  OpportunityID=@GUID and Status=1)) --机会
begin
	delete from OpportunityProduct where OpportunityID=@GUID and ProductDetailID=@ProductID

	select @TotalMoney=sum(TotalMoney) from OpportunityProduct where OpportunityID=@GUID

	update Opportunity set TotalMoney=isnull(@TotalMoney,0) where OpportunityID=@GUID
end
else if(@OrderType=11 and exists(select AutoID from Orders where  OrderID=@GUID and Status=1)) --订单
begin
	delete from OrderDetail where OrderID=@GUID and ProductDetailID=@ProductID

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@GUID

	update Orders set TotalMoney=isnull(@TotalMoney,0) where OrderID=@GUID
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