Use [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateUserAccount')
BEGIN
	DROP  Procedure  P_UpdateUserAccount
END

GO
/***********************************************************
过程名称： P_UpdateUserAccount
功能描述： 员工绑定账号
参数说明：	 
编写日期： 2016/7/28
程序作者： Allen
调试记录： exec P_UpdateUserAccount 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateUserAccount]
@UserID nvarchar(64),
@LoginName nvarchar(200),
@LoginPwd nvarchar(200)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran

declare @Err int=0

--账号已存在
IF  EXISTS(select AutoID from UserAccounts where AccountName=@LoginName and AccountType in(1,2))
begin
	rollback tran
	return
end

--已绑定账号
IF  EXISTS(select AutoID from UserAccounts where UserID=@UserID and AccountType=1)
begin
	rollback tran
	return
end

insert into UserAccounts(AccountName,AccountType,UserID,AgentID,ClientID)
values(@LoginName,1,@UserID,@AgentID,@ClientID)

if(@LoginPwd<>'')
begin
	update Users set LoginPWD=@LoginPwd where UserID=@UserID
end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end