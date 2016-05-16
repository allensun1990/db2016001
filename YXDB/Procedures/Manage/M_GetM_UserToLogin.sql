

Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_GetM_UserToLogin')
BEGIN
	DROP  Procedure  M_GetM_UserToLogin
END

GO
/***********************************************************
过程名称： M_GetM_UserToLogin
功能描述： 验证云销系统登录并返回信息
参数说明：	 
编写日期： 2016/4/20
程序作者： Michaux
调试记录： exec M_GetM_UserToLogin 'admin','F7D931C986841F4301D971C59F804409',0
************************************************************/
CREATE PROCEDURE [dbo].[M_GetM_UserToLogin]
@LoginName nvarchar(200),
@LoginPWD nvarchar(64),
@Result int output  --1:查询正常；2：用户名不存在；3：用户密码有误
AS

declare @UserID nvarchar(64),@RoleID nvarchar(64)

IF  EXISTS(select UserID from M_Users where LoginName=@LoginName  and Status<>9)
begin
	select @UserID = UserID,@RoleID=RoleID from M_Users 
	where LoginName=@LoginName and LoginPWD=@LoginPWD and Status=1
	
	if(@UserID is not null)
	begin
		set @Result=1
		--会员信息
		select * from M_Users where UserID=@UserID
		--权限信息
		select m.* from Menu m left join M_RolePermission r on r.MenuCode=m.MenuCode 
		where [Type] =2 and (RoleID=@RoleID or IsLimit=0 )

	end
	else
		set @Result=3
end
else
set @Result=2

 

