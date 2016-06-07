Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_InsertClient')
BEGIN
	DROP  Procedure  M_InsertClient
END

GO
/***********************************************************
过程名称： M_InsertClient
功能描述： 添加客户端
参数说明：	 
编写日期： 2015/4/10
程序作者： Allen
调试记录： exec M_InsertClient 
************************************************************/
CREATE PROCEDURE [dbo].[M_InsertClient]
@ClientID nvarchar(64),
@CompanyName nvarchar(200),
@MobilePhone nvarchar(64)='',
@Industry nvarchar(64)='',
@CityCode nvarchar(10)='',
@Address nvarchar(200)='',
@Description nvarchar(200)='',
@ContactName nvarchar(50),
@BindMobilePhone nvarchar(200)='',
@LoginPWD nvarchar(64)='',
@Email nvarchar(200)='',
@MDUserID nvarchar(64)='',
@MDProjectID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 账号已存在
AS

begin tran

set @Result=0

declare @Err int ,@DepartID nvarchar(64),@RoleID nvarchar(64),@UserID nvarchar(64),@AgentID nvarchar(64),@WareID nvarchar(64)

select @Err=0,@DepartID=NEWID(),@RoleID=NEWID(),@UserID=NEWID(),@AgentID=NEWID(),@WareID=NEWID()


--账号已存在
if(@BindMobilePhone<>'' and exists(select UserID from Users where (LoginName=@BindMobilePhone or BindMobilePhone=@BindMobilePhone) and Status<>9))
begin
	set @Result=2
	rollback tran
	return
end

--明道网络已存在
if(@MDProjectID<>'' and exists(select AgentID from Agents where MDProjectID=@MDProjectID))
begin
	set @Result=2
	rollback tran
	return
end

--明道账号已存在
if(@MDUserID<>'' and exists(select UserID from Users where MDUserID=@MDUserID))
begin
	set @Result=2
	rollback tran
	return
end


if(@MobilePhone='')
begin
	set @MobilePhone=@BindMobilePhone
end

--客户端
insert into Clients(ClientID,CompanyName,ContactName,MobilePhone,Status,Industry,CityCode,Address,Description,AgentID,CreateUserID,UserQuantity,EndTime) 
				values(@ClientID,@CompanyName,@ContactName,@MobilePhone,1,@Industry,@CityCode,@Address,@Description,@AgentID,@CreateUserID,20,dateadd(MONTH, 2, GETDATE()) )

set @Err+=@@error

--直营代理商
insert into Agents(AgentID,CompanyName,Status,IsDefault,MDProjectID,ClientID,UserQuantity,EndTime) 
			values(@AgentID,'公司直营',1,1,@MDProjectID,@ClientID,20,dateadd(MONTH, 2, GETDATE()))

--部门
insert into Department(DepartID,Name,Status,CreateUserID,AgentID,ClientID) values (@DepartID,'系统管理',1,@UserID,@AgentID,@ClientID)
set @Err+=@@error

--角色
insert into Role(RoleID,Name,Status,IsDefault,CreateUserID,AgentID,ClientID) values (@RoleID,'系统管理员',1,1,@UserID,@AgentID,@ClientID)

set @Err+=@@error

insert into Users(UserID,BindMobilePhone,LoginPWD,Name,MobilePhone,Email,Allocation,Status,IsDefault,DepartID,RoleID,CreateUserID,MDUserID,MDProjectID,AgentID,ClientID)
             values(@UserID,@BindMobilePhone,@LoginPWD,@ContactName,@MobilePhone,@Email,1,1,1,@DepartID,@RoleID,@UserID,@MDUserID,@MDProjectID,@AgentID,@ClientID)

--部门关系
insert into UserDepart(UserID,DepartID,CreateUserID,ClientID) values(@UserID,@DepartID,@UserID,@ClientID)  
set @Err+=@@error
   
--角色关系
insert into UserRole(UserID,RoleID,CreateUserID,ClientID) values(@UserID,@RoleID,@UserID,@ClientID) 
set @Err+=@@error

--客户来源
insert into CustomSource(SourceID,SourceCode,SourceName,IsSystem,IsChoose,Status,CreateUserID,ClientID)
					values(NEWID(),'Source-Activity','活动',1,0,1,@UserID,@ClientID)
					
insert into CustomSource(SourceID,SourceCode,SourceName,IsSystem,IsChoose,Status,CreateUserID,ClientID)
					values(NEWID(),'Source-Manual','主动联系',1,1,1,@UserID,@ClientID)

--客户阶段
insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
values(NEWID(),'新客户',1,1,1,'',@UserID,@ClientID)
insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
values(NEWID(),'机会客户',2,1,2,'',@UserID,@ClientID)
insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
values(NEWID(),'成交客户',3,1,3,'',@UserID,@ClientID)

--机会阶段
insert into [OpportunityStage] (StageID,StageName,Probability,Sort,Status,Mark,PID,CreateUserID,ClientID) 
values (NEWID(),'初步沟通',0.10,1,1,1,'',@UserID,@ClientID)
insert into [OpportunityStage] (StageID,StageName,Probability,Sort,Status,Mark,PID,CreateUserID,ClientID)
values (NEWID(),'合同确认',0.5,2,1,0,'',@UserID,@ClientID) 
insert into [OpportunityStage] (StageID,StageName,Probability,Sort,Status,Mark,PID,CreateUserID,ClientID)
values (NEWID(),'转为订单',1,3,1,2,'',@UserID,@ClientID) 

--仓库
insert into WareHouse(WareID,WareCode,Name,Status,CreateUserID,ClientID)
values(@WareID,'Ware001','主仓库',1,@UserID,@ClientID)

insert into DepotSeat(DepotID,DepotCode,WareID,Name,Status,CreateUserID,ClientID)
values(NEWID(),'Depot001',@WareID,'主货位',1,@UserID,@ClientID)

--单位
insert into ProductUnit(UnitID,UnitName,Status,CreateUserID,ClientID)
values(NEWID(),'个',1,@UserID,@ClientID)

--订单类型
insert into OrderType(TypeID,TypeCode,TypeName,Status,CreateUserID,ClientID)
values(NEWID(),'Normal','普通订单',1,@UserID,@ClientID)

--供应商
insert into Providers(ProviderID,Name,Contact,MobileTele,Email,Website,CityCode,Address,Remark,CreateTime,CreateUserID,AgentID,ClientID)
			 values (NEWID(),'公司直营',@CompanyName,@MobilePhone,@Email,'',@CityCode,@Address,'',GETDATE(),@UserID,@AgentID,@ClientID)
			 

--将客户端作为云销客户插入客户表

declare @DefaultClientID nvarchar(64),@DefaultAgentID nvarchar(64),@SourceID nvarchar(64),@StageID nvarchar(64)

select @DefaultClientID=ClientID,@DefaultAgentID=AgentID from Clients where IsDefault=1

select @StageID=StageID from  CustomStage where ClientID=@DefaultClientID and Mark=1

if(@MDProjectID<>'')
begin
	select @SourceID=SourceID from CustomSource where ClientID=@DefaultClientID and SourceCode='MD'
end
else
begin
	select @SourceID=SourceID from CustomSource where ClientID=@DefaultClientID and SourceCode='Self'
end


insert into Customer(CustomerID,Name,Type,IndustryID,CityCode,Address,MobilePhone,Email,AgentID,ClientID,SourceID,StageID)
values( @ClientID,@CompanyName,1,@Industry,@CityCode,@Address,@MobilePhone,@Email,@DefaultAgentID,@DefaultClientID ,@SourceID,@StageID)

--插入客户联系人
if(@ContactName<>'')
begin
insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,Email,Jobs,Status,OwnerID,CustomerID,CreateUserID,AgentID,ClientID)
values( NEWID(),@ContactName,1,@MobilePhone,'',@Email,'',1,'',@ClientID,'',@DefaultAgentID,@DefaultClientID)
end

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end