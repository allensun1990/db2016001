Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderPlanTime')
BEGIN
	DROP  Procedure  P_UpdateOrderPlanTime
END

GO
/***********************************************************
过程名称： P_UpdateOrderPlanTime
功能描述： 修改订单交货日期
参数说明：	 
编写日期： 2017/11/1
程序作者： Allen
调试记录： exec P_UpdateOrderPlanTime 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderPlanTime]
	@OrderID nvarchar(64),
	@PlanTime nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int

select @Status=OrderStatus from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status>=2)
begin
	rollback tran
	return
end

Update Orders set PlanTime=@PlanTime where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

