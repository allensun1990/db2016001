Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteUserByID')
BEGIN
	DROP  Procedure  P_DeleteUserByID
END

GO
/***********************************************************
过程名称： P_DeleteUserByID
功能描述： 删除员工
参数说明：	 
编写日期： 2015/10/24
程序作者： Allen
调试记录： exec P_DeleteUserByID 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteUserByID]
@UserID nvarchar(64),
@AgentID nvarchar(64),
@Result int output --0：失败，1：成功
AS

begin tran

set @Result=0

declare @Err int=0,@RoleID nvarchar(64)

--防止自杀式删除用户，管理员至少保留一个
select @RoleID from Users where UserID=@UserID and AgentID=@AgentID
if exists (select AutoID from Role where RoleID=@RoleID and IsDefault=1)
begin
	if not exists(select UserID from Users where RoleID=@RoleID and Status=1 and UserID<>@UserID)
	begin
		set @Result=0
		rollback tran
		return
	end
end

Update Users set Status=9,ParentID='',RoleID='' where UserID=@UserID and AgentID=@AgentID

Update Users set ParentID='' where ParentID=@UserID

Update UserRole set Status=9 where UserID=@UserID and Status=1

set @Err+=@@error

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end