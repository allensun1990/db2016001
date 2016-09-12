Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_BindOtherAccount')
BEGIN
	DROP  Procedure  P_BindOtherAccount
END

GO
/***********************************************************
过程名称： M_BindOtherAccount
功能描述： 给用户绑定微信ID
参数说明：	 
编写日期： 2016/7/17
程序作者： Michaux
调试记录： exec P_BindOtherAccount 
************************************************************/
CREATE PROCEDURE [dbo].[P_BindOtherAccount]
@ClientID nvarchar(64),
@AgentID nvarchar(64),
@UserID nvarchar(64),
@ProjectID nvarchar(64),
@AccountName  nvarchar(64),
@AccountType int =0, 
@Result nvarchar(200) output
AS
 
	set @Result=''
	declare @OriginalWeiXinID nvarchar(64)=''
	
	if(@AccountType=4 and exists(select AutoID from Agents where CMClientID=@ProjectID))
	begin
		set @Result='此工厂已被绑定，不能重复操作'
		return @Result
	end
	else if(@AccountType=4 and exists(select AutoID from Agents where AgentID=@AgentID and CMClientID<>'' and CMClientID is not null))
	begin
		set @Result='此账户已绑定工厂，不能重复绑定'
		return @Result
	end

	if exists(select AutoID from UserAccounts where UserID=@UserID and AccountType=@AccountType)
	begin
		set @Result='用户已绑定此账号，不能重复绑定'
		return @Result
	end

	if(	@ProjectID<>'' and exists(select AutoID from UserAccounts where AccountName=@AccountName and ProjectID=@ProjectID and AccountType=@AccountType))
	begin 
		set @Result='此外部账号被使用过，不能重复绑定'
		return @Result
	end
	else if (@ProjectID='' and exists(select AutoID from UserAccounts where AccountName=@AccountName and AccountType=@AccountType))
	begin
		set @Result='此外部账号被使用过，不能重复绑定'
		return @Result
	end

	insert into UserAccounts (AccountName,ProjectID,AccountType,UserID,AgentID,ClientID)
	values( @AccountName,@ProjectID,@AccountType,@UserID,@AgentID,@ClientID)
