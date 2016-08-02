Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetUserByOtherAccount')
BEGIN
	DROP  Procedure  P_GetUserByOtherAccount
END

GO
/***********************************************************
过程名称： P_GetUserByOtherAccount
功能描述： 根据明道ID获取信息
参数说明：	 
编写日期： 2015/10/20
程序作者： Allen
调试记录： exec P_GetUserByOtherAccount '' 
修改记录： Michaux 2016/08/02  添加 and IsLimit=1 过滤掉部分不需要加载的菜单项
************************************************************/
CREATE PROCEDURE [dbo].[P_GetUserByOtherAccount]
@MDUserID nvarchar(64),
@MDProjectID nvarchar(64),
@AccouType int=3
AS

declare @UserID nvarchar(64),@ClientID nvarchar(64),@AgentID nvarchar(64),@RoleID nvarchar(64)
 
IF  EXISTS(select AutoID from UserAccounts where AccountName=@MDUserID and ProjectID=@MDProjectID and AccountType =@AccouType)
begin
	select @UserID=UserID from UserAccounts where AccountName=@MDUserID and ProjectID=@MDProjectID and AccountType =@AccouType

	select @RoleID=RoleID from Users where UserID=@UserID

	--select RoleID into #Roles from UserRole where UserID=@UserID and Status=1

	--会员信息
	select * from Users where UserID=@UserID

	--权限信息
	select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode  and IsLimit=1
	where (RoleID=@RoleID or IsLimit=0 )

end 

