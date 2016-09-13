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
 
declare @Err int=0

 begin tran

	set @Result=''

	if exists(select AutoID from UserAccounts where UserID=@UserID and AccountType=@AccountType)
	begin
		set @Result='用户已绑定此账号，不能重复绑定'
		rollback tran
		return 
	end

	if(	@ProjectID<>'' and exists(select AutoID from UserAccounts where AccountName=@AccountName and ProjectID=@ProjectID and AccountType=@AccountType))
	begin 
		set @Result='此外部账号被使用过，不能重复绑定'
		rollback tran
		return 
	end
	else if (@ProjectID='' and exists(select AutoID from UserAccounts where AccountName=@AccountName and AccountType=@AccountType))
	begin
		set @Result='此外部账号被使用过，不能重复绑定'
		rollback tran
		return 
	end
	set @Err+=@@error


	insert into UserAccounts (AccountName,ProjectID,AccountType,UserID,AgentID,ClientID)
	values(@AccountName,@ProjectID,@AccountType,@UserID,@AgentID,@ClientID)
	set @Err+=@@error

	if(@Err>0)
	begin
		set @Result='账号绑定失败'
		rollback tran
	end 
	else
	begin
		commit tran
	end