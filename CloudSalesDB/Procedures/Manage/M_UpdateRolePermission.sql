Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateRolePermission')
BEGIN
	DROP  Procedure  M_UpdateRolePermission
END

GO
/***********************************************************
过程名称： M_UpdateRolePermission
功能描述： 编辑角色权限
参数说明：	 
编写日期： 2015/10/21
程序作者： Allen
调试记录： exec M_UpdateRolePermission 
************************************************************/
CREATE PROCEDURE [dbo].[M_UpdateRolePermission]
@RoleID nvarchar(64),
@Permissions nvarchar(4000)='',
@UserID nvarchar(64)
AS

begin tran

set @Permissions='''' + REPLACE(@Permissions,',',''',''') + ''''

declare @Err int=0

delete from M_RolePermission where RoleID=@RoleID

exec('insert into M_RolePermission(RoleID,MenuCode,CreateUserID) select '''+@RoleID+''',MenuCode,'''+@UserID+''' from Menu where MenuCode in('+@Permissions+')')
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end