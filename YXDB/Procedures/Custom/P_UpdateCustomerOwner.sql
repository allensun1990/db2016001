Use IntFactory
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
	@ClientID nvarchar(64)=''
AS
declare @Err int=0,@OldOwnerID nvarchar(64)

select @OldOwnerID=OwnerID from Customer where CustomerID=@CustomerID  and ClientID=@ClientID

if(@OldOwnerID=@UserID)
begin
	return
end

begin tran
update Customer set OwnerID=@UserID where CustomerID=@CustomerID and ClientID=@ClientID
update Contact set OwnerID=@UserID where CustomerID=@CustomerID and ClientID=@ClientID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

