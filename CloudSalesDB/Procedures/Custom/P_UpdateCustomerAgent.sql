Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCustomerAgent')
BEGIN
	DROP  Procedure  P_UpdateCustomerAgent
END

GO
/***********************************************************
过程名称： P_UpdateCustomerAgent
功能描述： 更换客户代理商
参数说明：	 
编写日期： 2015/11/5
程序作者： Allen
调试记录： exec P_UpdateCustomerAgent 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateCustomerAgent]
	@CustomerID nvarchar(64)='',
	@NewAgentID nvarchar(64)='',
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0


update Customer set OwnerID='',AgentID=@NewAgentID,AllocationTime=null where CustomerID=@CustomerID 

set @Err+=@@error

--处理拥有着记录
update CustomerOwner set status=9 where CustomerID=@CustomerID and status=1

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

