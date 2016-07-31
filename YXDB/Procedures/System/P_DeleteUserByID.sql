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
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功
AS

begin tran

set @Result=0

declare @Err int=0,@RoleID nvarchar(64)

--绑定阿里的账号不能删除
if exists(select AutoID from UserAccounts where UserID=@UserID and AccountType=3)
begin
	set @Result=0
	rollback tran
	return
end

--防止自杀式删除用户，管理员至少保留一个
select @RoleID=RoleID from Users where UserID=@UserID and ClientID=@ClientID

if exists (select AutoID from Role where RoleID=@RoleID and IsDefault=1)
begin
	if not exists(select UserID from Users where RoleID=@RoleID and Status=1 and UserID<>@UserID)
	begin
		set @Result=0
		rollback tran
		return
	end
end

Update Users set Status=9,ParentID='',RoleID='' where UserID=@UserID and ClientID=@ClientID

Update Users set ParentID='' where ParentID=@UserID

--清空账号信息
delete from UserAccounts where UserID=@UserID 

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