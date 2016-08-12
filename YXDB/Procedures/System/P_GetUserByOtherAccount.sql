Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetUserByOtherAccount')
BEGIN
	DROP  Procedure  P_GetUserByOtherAccount
END

GO
/***********************************************************
过程名称： P_GetUserByOtherAccount
功能描述： 根据第三方获取信息
参数说明：	 
编写日期： 2016/7/28
程序作者： Allen
调试记录： exec P_GetUserByOtherAccount ''
************************************************************/
CREATE PROCEDURE [dbo].[P_GetUserByOtherAccount]
@AccountType int,
@Account nvarchar(200),
@ProjectID nvarchar(200)=''
AS

declare @UserID nvarchar(64),@ClientID nvarchar(64),@RoleID nvarchar(64)
IF  EXISTS(select AutoID from UserAccounts where AccountName=@Account and AccountType = @AccountType )
begin

	select @UserID=UserID from UserAccounts where AccountName=@Account and AccountType = @AccountType
	select @ClientID=ClientID,@RoleID=RoleID from Users where UserID=@UserID

	select * from Users where UserID=@UserID

	--权限信息
	select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode  and IsLimit=1
	where (RoleID=@RoleID or IsLimit=0 )

	--更新微信公众号openid
	if(@AccountType=4 and @ProjectID<>'')
		update UserAccounts set ProjectID=@ProjectID  where AccountName=@Account and AccountType = @AccountType
end

 

