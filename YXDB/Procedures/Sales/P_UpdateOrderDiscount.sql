Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderDiscount')
BEGIN
	DROP  Procedure  P_UpdateOrderDiscount
END

GO
/***********************************************************
过程名称： P_UpdateOrderDiscount
功能描述： 修改订单利润比例
参数说明：	 
编写日期： 2016/3/21
程序作者： Allen
调试记录： exec P_UpdateOrderDiscount 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderDiscount]
	@OrderID nvarchar(64),
	@Discount decimal(18,4)=0 ,
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int

select @Status=Status from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status>4)
begin
	rollback tran
	return
end

Update Orders set Discount=@Discount,FinalPrice=OriginalPrice*@Discount,TotalMoney=OriginalPrice*PlanQuantity*@Discount where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

