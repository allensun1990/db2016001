Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOrder')
BEGIN
	DROP  Procedure  P_DeleteOrder
END

GO
/***********************************************************
过程名称： P_DeleteOrder
功能描述： 删除订单
参数说明：	 
编写日期： 2015/11/15
程序作者： Allen
调试记录： exec P_DeleteOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteOrder]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@CustomerID nvarchar(64)

select @Status=Status,@CustomerID=CustomerID from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status > 1)
begin
	rollback tran
	return
end


Update Orders set Status=9 where OrderID=@OrderID

update Customer set OrderCount=OrderCount-1 where CustomerID=@CustomerID and OrderCount>0

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

