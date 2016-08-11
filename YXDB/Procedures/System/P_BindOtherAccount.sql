Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_BindOtherAccount')
BEGIN
	DROP  Procedure  P_BindOtherAccount
END

GO
/***********************************************************
过程名称： P_BindOtherAccount
功能描述： 绑定第三方账号
参数说明：	 
编写日期： 2016/7/28
程序作者： Allen
调试记录： exec P_BindOtherAccount ''
************************************************************/
CREATE PROCEDURE [dbo].[P_BindOtherAccount]
@UserID nvarchar(64),
@AccountType int,
@Account nvarchar(200),
@ClientID nvarchar(64),
@ProjectID nvarchar(200)=''
AS

IF not EXISTS(select AutoID from UserAccounts where AccountName=@Account and AccountType = @AccountType)
begin	
	if(@AccountType=3)
	begin
		Update Clients set AliMemberID=@Account where ClientID=@ClientID
	end
	insert into UserAccounts(AccountName,AccountType,UserID,ClientID,ProjectID)
	values(@Account,@AccountType,@UserID,@ClientID,@ProjectID)


end

 

