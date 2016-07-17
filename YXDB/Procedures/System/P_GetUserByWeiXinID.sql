Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetUserByWeiXinID')
BEGIN
	DROP  Procedure  P_GetUserByWeiXinID
END

GO
/***********************************************************
过程名称： P_GetUserByWeiXinID
功能描述： 根据阿里会员ID获取信息
参数说明：	 
编写日期： 2015/10/20
程序作者： Allen
调试记录： exec P_GetUserByWeiXinID ''
************************************************************/
CREATE PROCEDURE [dbo].[P_GetUserByWeiXinID]
@WeiXinID nvarchar(200)
AS

declare @UserID nvarchar(64),@ClientID nvarchar(64),@AgentID nvarchar(64),@RoleID nvarchar(64)

select @UserID = UserID,@ClientID=ClientID,@AgentID=AgentID,@RoleID=RoleID from Users where WeiXinID=@WeiXinID

if(@UserID is not null)
begin
	--会员信息
	select * from Users where UserID=@UserID

	--权限信息
	select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode 
	where (RoleID=@RoleID or IsLimit=0 )

end

 

