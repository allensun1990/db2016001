Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateUserAccountPwd')
BEGIN
	DROP  Procedure  P_UpdateUserAccountPwd
END

GO
/***********************************************************
过程名称： P_UpdateUserAccountPwd
功能描述： 通过手机号编辑密码
参数说明：	 
编写日期： 2016/7/6
程序作者： Allen
调试记录： exec P_UpdateUserAccountPwd 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateUserAccountPwd]
@LoginName nvarchar(200),
@LoginPwd nvarchar(200)
AS

begin tran

declare @Err int=0,@UserID nvarchar(64)

--手机账号不存在
IF not EXISTS(select AutoID from UserAccounts where AccountName=@LoginName and AccountType =2 )
begin
	rollback tran
	return
end

select @UserID=UserID from UserAccounts where AccountName=@LoginName and AccountType =2 

update Users set LoginPWD=@LoginPwd where UserID=@UserID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end