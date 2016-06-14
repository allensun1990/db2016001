Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderProductPrice')
BEGIN
	DROP  Procedure  P_UpdateOrderProductPrice
END

GO
/***********************************************************
过程名称： P_UpdateOrderProductPrice
功能描述： 修改订单产品单价
参数说明：	 
编写日期： 2016/6/13
程序作者： Allen
调试记录： exec P_UpdateOrderProductPrice 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderProductPrice]
	@OrderID nvarchar(64),
	@ProductID nvarchar(64) ,
	@Price decimal(18,4)=0 ,
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)



if not exists(select AutoID from Orders where OrderID=@OrderID and ClientID=@ClientID and Status=1)
begin
	rollback tran
	return
end

update OrderDetail set Price=@Price,TotalMoney=@Price*Quantity where OrderID=@OrderID and ProductDetailID=@ProductID

select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID

Update Orders set TotalMoney=@TotalMoney where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

