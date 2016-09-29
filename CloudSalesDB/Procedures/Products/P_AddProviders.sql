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
修改信息： Michaux 2016-09-12  添加供应商来源类型--0：手动注册 1：智能工厂 2：二当家
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
@ClientID nvarchar(64),
@ProviderType int =0  --0：手动注册 1：智能工厂 2：二当家
AS

if(@CMClientID<>'' and exists(select AutoID from Providers where ClientID=@ClientID and CMClientID=@CMClientID and Status<>9))
begin
	return
end

declare @Err int=0,@PAgentID nvarchar(64),@SourceType nvarchar(64)

begin tran
if(@CMClientID<>'' and exists(select AutoID from Providers where ClientID=@ClientID and CMClientID=@CMClientID and Status=9))
begin
	Update Providers set Status=1 where ClientID=@ClientID and CMClientID=@CMClientID
end
else
begin
	insert into Providers(ProviderID,Name,Contact,MobileTele,Email,Website,CityCode,Address,Remark,CreateTime,CMClientID,CMClientCode,CreateUserID,AgentID,ClientID,ProviderType)
               values(@ProviderID ,@Name,@Contact ,@MobileTele,@Email,'',@CityCode,@Address,@Remark,getdate(),@CMClientID,@CMClientCode,@CreateUserID,@AgentID,@ClientID,@ProviderType)
end

set @Err+=@@error

if(@CMClientID<>'' and  @ProviderType=1)
begin
	Update Agents set CMClientID=@CMClientID,IsMall=1 where AgentID=@AgentID and (CMClientID ='' or CMClientID is null)
	Update Clients set CMClientID=@CMClientID,IsMall=1 where ClientID=@ClientID and (CMClientID ='' or CMClientID is null)
end
set @Err+=@@error
if(@CMClientID<>'' and  @ProviderType=2 and not exists(select AutoID from Customer where ChildClientID=@ClientID and ClientID=@CMClientID))
begin

	select @PAgentID=AgentID from Clients where ClientID=@CMClientID
	select @SourceType=SourceID from CustomSource where SourceCode='Source-Self' and ClientID=@CMClientID

	insert into Customer(CustomerID,Name,ContactName,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,ActivityID,
					StageID,OwnerID,Status,AllocationTime,OrderTime,CreateTime,CreateUserID,AgentID,ClientID,MemberLevelID,IntegerFee,ChildClientID)
	select NewID(),CompanyName,ContactName,1,'','',CityCode,Address,MobilePhone,'','','','',@SourceType,'',
					2,'',1,null,null,getdate(),'',@PAgentID,@CMClientID,'',0,@ClientID from Clients where ClientID=@ClientID
end
set @Err+=@@error
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end