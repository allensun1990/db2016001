﻿Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'GetUserByMDUserID')
BEGIN
	DROP  Procedure  GetUserByMDUserID
END

GO
/***********************************************************
过程名称： GetUserByMDUserID
功能描述： 根据明道ID获取信息
参数说明：	 
编写日期： 2015/10/20
程序作者： Allen
调试记录： exec GetUserByMDUserID ''
************************************************************/
CREATE PROCEDURE [dbo].[GetUserByMDUserID]
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
	select m.* from Menu m left join RolePermission r on r.MenuCode=m.MenuCode 
	where (RoleID=@RoleID or IsLimit=0 )

end 

