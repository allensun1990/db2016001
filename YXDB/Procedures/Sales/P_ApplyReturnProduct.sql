Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ApplyReturnProduct')
BEGIN
	DROP  Procedure  P_ApplyReturnProduct
END

GO
/***********************************************************
过程名称： P_ApplyReturnProduct
功能描述： 退货申请
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_ApplyReturnProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_ApplyReturnProduct]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS
	
begin tran

set @Result=0

--订单信息
declare @Err int=0,@Status int,@OrderAgentID nvarchar(64),@OrderCode nvarchar(50),@TotalMoney decimal(18,4),@ReturnStatus nvarchar(64)
select @Status=Status,@OrderCode=OrderCode,@TotalMoney=TotalMoney,@ReturnStatus=ReturnStatus from Orders where OrderID=@OrderID and ClientID=@ClientID

if(@Status<>2 or @ReturnStatus=1)
begin
	rollback tran
	return
end

--代理商信息

--订单状态					
Update Orders set ReturnStatus=1 where OrderID=@OrderID
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 

