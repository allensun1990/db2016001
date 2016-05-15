Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetUserToLogin')
BEGIN
	DROP  Procedure  P_GetUserToLogin
END

GO
/***********************************************************
过程名称： P_GetUserToLogin
功能描述： 验证云销系统登录并返回信息
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

declare @UserID nvarchar(64),@ClientID nvarchar(64),@AgentID nvarchar(64),@RoleID nvarchar(64)

IF  EXISTS(select UserID from Users where (LoginName=@LoginName or BindMobilePhone=@LoginName) and Status<>9)
begin

	select @UserID = UserID,@ClientID=ClientID,@AgentID=AgentID,@RoleID=RoleID from Users 
	where (LoginName=@LoginName or BindMobilePhone=@LoginName) and LoginPWD=@LoginPWD and Status=1

	if(@UserID is not null)
	begin
		set @Result=1
		--select RoleID into #Roles from UserRole where UserID=@UserID and Status=1

		--会员信息
		select * from Users where UserID=@UserID

		--权限信息
		select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode 
		where (RoleID=@RoleID or IsLimit=0 )

	end
	else
		set @Result=3

end
else
set @Result=2

 

