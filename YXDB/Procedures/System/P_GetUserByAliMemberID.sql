Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetUserByAliMemberID')
BEGIN
	DROP  Procedure  P_GetUserByAliMemberID
END

GO
/***********************************************************
过程名称： P_GetUserByAliMemberID
功能描述： 根据阿里会员ID获取信息
参数说明：	 
编写日期： 2015/10/20
程序作者： Allen
调试记录： exec P_GetUserByAliMemberID ''
************************************************************/
CREATE PROCEDURE [dbo].[P_GetUserByAliMemberID]
@AliMemberID nvarchar(64)
AS

declare @UserID nvarchar(64),@ClientID nvarchar(64),@AgentID nvarchar(64),@RoleID nvarchar(64)

select @UserID = UserID,@ClientID=ClientID,@AgentID=AgentID,@RoleID=RoleID from Users where AliMemberID=@AliMemberID  and Status=1

if(@UserID is not null)
begin
	--会员信息
	select * from Users where UserID=@UserID

	--权限信息
	select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode 
	where (RoleID=@RoleID or IsLimit=0 )

end

 

