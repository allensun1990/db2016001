Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_BindCMClient')
BEGIN
	DROP  Procedure  P_BindCMClient
END

GO
/***********************************************************
过程名称： P_BindCMClient
功能描述： 客户绑定厂盟
参数说明：	 
编写日期： 2016/9/13
程序作者： Allen
调试记录： exec P_BindCMClient 
************************************************************/
CREATE PROCEDURE [dbo].[P_BindCMClient]
@UserID nvarchar(64),
@ProjectID nvarchar(64),
@AccountName  nvarchar(64),
@CompanyName nvarchar(100)='',
@Name nvarchar(50)='',
@Mobile nvarchar(50)='',
@CityCode nvarchar(20)='',
@Address nvarchar(400)='',
@AgentID nvarchar(64),
@ClientID nvarchar(64),
@Result nvarchar(200) output
AS
 
declare @Err int=0

 begin tran

	set @Result=''
	
	if exists(select AutoID from Agents where CMClientID=@ProjectID)
	begin
		set @Result='此工厂已被绑定，不能重复操作'
		rollback tran
		return 
	end
	else if exists(select AutoID from Agents where AgentID=@AgentID and CMClientID<>'' and CMClientID is not null)
	begin
		set @Result='此账户已绑定工厂，不能重复绑定'
		rollback tran
		return 
	end

	if exists(select AutoID from UserAccounts where UserID=@UserID and AccountType=4)
	begin
		set @Result='用户已绑定此账号，不能重复绑定'
		rollback tran
		return 
	end

	if exists(select AutoID from UserAccounts where AccountName=@AccountName and ProjectID=@ProjectID and AccountType=4)
	begin 
		set @Result='此外部账号被使用过，不能重复绑定'
		rollback tran
		return 
	end

	set @Err+=@@error

	Update Agents set CMClientID=@ProjectID,IsMall=1 where AgentID=@AgentID

	insert into UserAccounts (AccountName,ProjectID,AccountType,UserID,AgentID,ClientID)
	values(@AccountName,@ProjectID,4,@UserID,@AgentID,@ClientID)
	set @Err+=@@error

	insert into Providers(ProviderID,Name,Contact,MobileTele,Email,Website,CityCode,Address,Remark,CreateTime,CMClientID,CMClientCode,CreateUserID,AgentID,ClientID,ProviderType)
               values(NEWID() ,@CompanyName,@Name ,@Mobile,'','',@CityCode,@Address,'',getdate(),@ProjectID,'',@UserID,@AgentID,@ClientID,1)

	if(@Err>0)
	begin
		set @Result='账号绑定失败'
		rollback tran
	end 
	else
	begin
		commit tran
	end