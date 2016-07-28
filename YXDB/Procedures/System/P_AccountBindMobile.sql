Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AccountBindMobile')
BEGIN
	DROP  Procedure  P_AccountBindMobile
END

GO
/***********************************************************
过程名称： P_AccountBindMobile
功能描述： 初始化时 绑定手机号
参数说明：	 
编写日期： 2016/6/24
程序作者： MU
	修改： 2016/7/28 Allen
调试记录： exec P_AccountBindMobile 
************************************************************/
CREATE PROCEDURE [dbo].P_AccountBindMobile
@UserID nvarchar(64),
@BindMobile nvarchar(64),
@Pwd nvarchar(100),
@IsFirst int=0,
@AgentID nvarchar(64),
@ClientID nvarchar(64)=''
AS
declare @LoginPWD nvarchar(100),@Err int=0
begin tran

IF EXISTS(select AutoID from UserAccounts where UserID=@UserID and AccountType=2)
begin
	rollback tran
	return
end

IF  EXISTS(select AutoID from UserAccounts where AccountName=@BindMobile and AccountType in(1,2))
begin
	rollback tran
	return
end

if exists (select AutoID from UserAccounts where UserID=@UserID and AccountType=1)
begin
	Update Users set MobilePhone=@BindMobile where UserID=@UserID
	set @Err+=@@error
end
else
begin
	Update users set MobilePhone=@BindMobile,LoginPWD=@Pwd where UserID=@UserID
end

set @Err+=@@error

insert into UserAccounts(AccountName,AccountType,UserID,AgentID,ClientID)
values(@BindMobile,2,@UserID,@AgentID,@ClientID)

set @Err+=@@error

if(@IsFirst=1)
begin
	update Clients set MobilePhone=@BindMobile where ClientID=@ClientID
	set @Err+=@@error

	Update Clients set GuideStep=0 where ClientID=@ClientID
	set @Err+=@@error
end
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end