Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_BindOtherAccount')
BEGIN
	DROP  Procedure  M_BindOtherAccount
END

GO
/***********************************************************
过程名称： M_BindOtherAccount
功能描述： 给用户绑定微信ID
参数说明：	 
编写日期： 2016/7/17
程序作者： Michaux
调试记录： exec M_BindOtherAccount 
************************************************************/
CREATE PROCEDURE [dbo].[M_BindOtherAccount]
@ClientiD nvarchar(64),
@AgentID nvarchar(64),
@UserID nvarchar(64),
@ProjectID nvarchar(64),
@AccountName  nvarchar(64),
@AccountType int =0, 
@Result nvarchar(200) output
AS
 
	set @Result=''
	declare @OriginalWeiXinID nvarchar(64)=''
  
	if(	@ProjectID<>'')
	begin 
		select @OriginalWeiXinID=AccountName from UserAccounts where  UserID=@UserID  AND ClientiD=@ClientiD  and AccountName=@AccountName and ProjectID=@ProjectID
	end
	else
	begin
		select @OriginalWeiXinID=AccountName from UserAccounts where  UserID=@UserID  AND ClientiD=@ClientiD  and AccountName=@AccountName
	end

	if(@OriginalWeiXinID<>'' )
	begin
			 set @Result='此外部账号被使用过，不能重复绑定'
		return @Result
	end
	insert into UserAccounts values( @AccountName,@ProjectID,@AccountType,@UserID,@AgentID,@ClientiD)
	if(isnull(SCOPE_IDENTITY(),0)<=0)
	begin
		set @Result='操作失败'
	end  