Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddProviders')
BEGIN
	DROP  Procedure  P_AddProviders
END

GO
/***********************************************************
过程名称： P_AddProviders
功能描述： 添加供应商
参数说明：	 
编写日期： 2016/7/7
程序作者： Allen
调试记录： exec P_AddProviders 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddProviders]
@ProviderID nvarchar(64),
@Name nvarchar(200),
@Contact nvarchar(50)='',
@MobileTele nvarchar(50)='',
@Email nvarchar(200)='',
@CityCode nvarchar(20)='',
@Address nvarchar(400)='',
@Remark nvarchar(4000)='',
@CMClientID nvarchar(100)='',
@CMClientCode nvarchar(100)='',
@CreateUserID nvarchar(64),
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS

if(@CMClientID<>'' and exists(select AutoID from Providers where ClientID=@ClientID and CMClientID=@CMClientID and Status<>9))
begin
	return
end

begin tran

declare @Err int=0

insert into Providers(ProviderID,Name,Contact,MobileTele,Email,Website,CityCode,Address,Remark,CreateTime,CMClientID,CMClientCode,CreateUserID,AgentID,ClientID)
               values(@ProviderID ,@Name,@Contact ,@MobileTele,@Email,'',@CityCode,@Address,@Remark,getdate(),@CMClientID,@CMClientCode,@CreateUserID,@AgentID,@ClientID)

if(@CMClientID<>'')
begin
	Update Agents set IsIntFactory=1 where AgentID=@AgentID and IsIntFactory=0
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end