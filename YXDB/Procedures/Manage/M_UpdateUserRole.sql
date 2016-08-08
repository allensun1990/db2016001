Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateUserRole')
BEGIN
	DROP  Procedure  M_UpdateUserRole
END

GO
/***********************************************************
过程名称： M_UpdateUserRole
功能描述： 编辑员工角色
参数说明：	 
编写日期： 2015/10/21
程序作者： Allen
调试记录： exec M_UpdateUserRole 
************************************************************/
CREATE PROCEDURE [dbo].[M_UpdateUserRole]
@UserID nvarchar(64),
@RoleID nvarchar(64),
@OpreateID nvarchar(64)
AS

begin tran
declare @Err int =0 ,@OldRoleID nvarchar(64)

select @OldRoleID=RoleID from M_Users where UserID=@UserID 
--默认管理员角色至少保留一人
if(@OldRoleID is not null and @OldRoleID<>'' and exists(select AutoID from M_Role where RoleID=@OldRoleID and IsDefault=1))
begin
	if not exists(select AutoID from M_UserRole where RoleID=@OldRoleID and Status=1 and UserID<>@UserID)
	begin
		rollback tran
		return
	end
end

Update M_Users set RoleID=@RoleID where UserID=@UserID
set @Err+=@@error

--角色记录
Update M_UserRole set Status=9 where UserID=@UserID and Status=1

insert into M_UserRole(UserID,RoleID,Status,CreateUserID) values(@UserID,@RoleID,1,@OpreateID)

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end