Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateProfitPrice')
BEGIN
	DROP  Procedure  P_UpdateProfitPrice
END

GO
/***********************************************************
过程名称： P_UpdateProfitPrice
功能描述： 修改订单利润比例
参数说明：	 
编写日期： 2015/11/15
程序作者： Allen
调试记录： exec P_UpdateProfitPrice 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateProfitPrice]
	@OrderID nvarchar(64),
	@Profit decimal(18,4)=0 ,
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int

select @Status=Status from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status>=3)
begin
	rollback tran
	return
end

Update Orders set ProfitPrice=@Profit where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

