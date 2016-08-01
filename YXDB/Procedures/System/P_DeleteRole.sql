Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteRole')
BEGIN
	DROP  Procedure  P_DeleteRole
END

GO
/***********************************************************
过程名称： P_DeleteRole
功能描述： 删除角色
参数说明：	 
编写日期： 2015/10/21
程序作者： Allen
调试记录： exec P_DeleteRole 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteRole]
@RoleID nvarchar(64),
@Result int output --0：失败，1：成功，10002 角色存在员工
AS

begin tran

set @Result=0

declare @Err int=0

--角色存在员工
if exists(select AutoID from Users where RoleID=@RoleID and Status=1)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update Role set Status=9 where RoleID=@RoleID  and IsDefault = 0

delete from RolePermission where RoleID=@RoleID

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