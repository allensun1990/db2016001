Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCustomerOwner')
BEGIN
	DROP  Procedure  P_UpdateCustomerOwner
END

GO
/***********************************************************
过程名称： P_UpdateCustomerOwner
功能描述： 更换客户拥有着
参数说明：	 
编写日期： 2015/11/5
程序作者： Allen
调试记录： exec P_UpdateCustomerOwner 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateCustomerOwner]
	@CustomerID nvarchar(64)='',
	@UserID nvarchar(64)='',
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@OldOwnerID nvarchar(64)

select @OldOwnerID=OwnerID from Customer where CustomerID=@CustomerID  and ClientID=@ClientID

if(@OldOwnerID=@UserID)
begin
	rollback tran
	return
end

update Customer set OwnerID=@UserID,AgentID=@AgentID,AllocationTime=isnull(AllocationTime,getdate()) where CustomerID=@CustomerID and ClientID=@ClientID
update Contact set OwnerID=@UserID,AgentID=@AgentID where CustomerID=@CustomerID and ClientID=@ClientID

set @Err+=@@error

--处理拥有着记录
update CustomerOwner set status=9 where CustomerID=@CustomerID and status=1

insert into CustomerOwner(CustomerID,UserID,Status,CreateTime,CreateUserID,AgentID,ClientID)
	 values(@CustomerID,@UserID,1,getdate(),@OperateID,@AgentID,@ClientID)

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

