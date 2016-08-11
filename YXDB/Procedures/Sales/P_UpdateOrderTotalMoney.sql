Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderTotalMoney')
BEGIN
	DROP  Procedure  P_UpdateOrderTotalMoney
END

GO
/***********************************************************
过程名称： P_UpdateOrderTotalMoney
功能描述： 修改订单总金额
参数说明：	 
编写日期： 2016/7/13
程序作者： MU
调试记录： exec P_UpdateOrderTotalMoney 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderTotalMoney]
	@OrderID nvarchar(64),
	@TotalMoney decimal(18,4)=0 ,
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int

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

 


 

