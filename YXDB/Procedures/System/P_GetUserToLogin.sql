Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetUserToLogin')
BEGIN
	DROP  Procedure  P_GetUserToLogin
END

GO
/***********************************************************
过程名称： P_GetUserToLogin
功能描述： 验证登录并返回信息
参数说明：	 
编写日期： 2015/4/22
程序作者： Allen
调试记录： exec P_GetUserToLogin 'Admin','ADA9D527563353B415575BD5BAAE0469'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetUserToLogin]
@LoginName nvarchar(200),
@LoginPWD nvarchar(64),
@Result int output  --1:查询正常；2：用户名不存在；3：用户密码有误
AS

declare @UserID nvarchar(64),@ClientID nvarchar(64),@RoleID nvarchar(64)

--账号不存在
IF  EXISTS(select AutoID from UserAccounts where AccountName=@LoginName and AccountType in(1,2))
begin
	
	select @UserID=UserID from UserAccounts where AccountName=@LoginName and AccountType in(1,2)

	--密码不正确
	if exists(select AutoID from Users where UserID=@UserID and LoginPWD=@LoginPWD and Status=1)
	begin
		select @RoleID=RoleID from Users where UserID=@UserID

		set @Result=1
		--select RoleID into #Roles from UserRole where UserID=@UserID and Status=1

		--会员信息
		select * from Users where UserID=@UserID

		--权限信息
		select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode and IsLimit=1
		where (RoleID=@RoleID or IsLimit=0 )

	end
	else
	begin
		set @Result=3
	end
end
else
begin
	set @Result=2
end
 



 

