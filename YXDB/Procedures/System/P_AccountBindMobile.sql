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
调试记录： exec P_AccountBindMobile 
************************************************************/
CREATE PROCEDURE [dbo].P_AccountBindMobile
@UserID nvarchar(64),
@BindMobile nvarchar(64),
@Pwd nvarchar(100),
@ClientID nvarchar(64)=''
AS
declare @BindMobilePhone nvarchar(100),
@LoginPWD nvarchar(100)

if(not exists(select UserID from users where UserID=@UserID and Status<>9) )
begin
	return
end

select @BindMobilePhone=BindMobilePhone,@LoginPWD=LoginPWD from users where UserID=@UserID and Status<>9
if(@BindMobilePhone<>'')
begin
	return
end

begin tran
declare @Err int=0

if(@LoginPWD<>'')
begin
	Update users set MobilePhone=@BindMobile,BindMobilePhone=@BindMobile where UserID=@UserID
	set @Err+=@@error
end
else
begin
	Update users set MobilePhone=@BindMobile,BindMobilePhone=@BindMobile,LoginPWD=@Pwd where UserID=@UserID
	set @Err+=@@error
end

update clients set MobilePhone=@BindMobile where ClientID=@ClientID
set @Err+=@@error

update Agents set EndTime=dateadd(month, 1, EndTime) where AgentID=@ClientID
set @Err+=@@error

Update Clients set GuideStep=0 where ClientID=@ClientID
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end