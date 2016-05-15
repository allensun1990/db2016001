Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderOwner')
BEGIN
	DROP  Procedure  P_UpdateOrderOwner
END

GO
/***********************************************************
过程名称： P_UpdateOrderOwner
功能描述： 更换订单拥有着
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_UpdateOrderOwner 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderOwner]
	@OrderID nvarchar(64)='',
	@UserID nvarchar(64)='',
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@OldOwnerID nvarchar(64),@Status int

select @OldOwnerID=OwnerID,@Status=Status from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@OldOwnerID=@UserID)
begin
	rollback tran
	return
end

update Orders set OwnerID=@UserID,AgentID=@AgentID where OrderID=@OrderID and ClientID=@ClientID


set @Err+=@@error

--处理拥有着记录
if(@Status = 2)
begin
	update OrderUser set status=9 where OrderID=@OrderID and status=1

	insert into OrderUser(OrderID,UserID,Status,CreateTime,CreateUserID,AgentID,ClientID)
		 values(@OrderID,@UserID,1,getdate(),@OperateID,@AgentID,@ClientID)
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

 


 

