Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UnBindOtherAccount')
BEGIN
	DROP  Procedure  P_UnBindOtherAccount
END

GO
/***********************************************************
过程名称： P_UnBindOtherAccount
功能描述： 解绑第三方账号
参数说明：	 
编写日期： 2016/7/28
程序作者： Allen
调试记录： exec P_UnBindOtherAccount ''
************************************************************/
CREATE PROCEDURE [dbo].[P_UnBindOtherAccount]
@UserID nvarchar(64),
@AccountType int,
@Account nvarchar(200),
@ClientID nvarchar(64)
AS

IF EXISTS(select AutoID from UserAccounts where UserID=@UserID and AccountType <> @AccountType)
begin	
	if(@AccountType=3)
	begin
		Update Clients set AliMemberID='' where ClientID=@ClientID
	end
	delete from UserAccounts where UserID=@UserID and AccountType=@AccountType
end

 

