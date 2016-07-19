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
修改信息:  Michaux 2016-07-14 添加来源类型 添加默认会员
************************************************************/
CREATE PROCEDURE [dbo].[M_InsertClient]
@ClientID nvarchar(64),
@ClientCode nvarchar(50)='',
@RegisterType int=0,
@AccountType int =0,
@Account nvarchar(200),
@LoginPWD nvarchar(64)='',
@ClientName nvarchar(500)='',
@ContactName nvarchar(50),
@MobilePhone nvarchar(64)='',
@Email nvarchar(200)='',
@Industry nvarchar(64)='',
@CityCode nvarchar(10)='',
@Address nvarchar(200)='',
@Description nvarchar(200)='',
@CompanyID nvarchar(200)='',
@CompanyCode nvarchar(200)='',
@CustomerID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@UserID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 账号已存在
AS

begin tran

set @Result=0

if(@UserID='')
begin
	set @UserID=NEWID()
end

declare @Err int ,@DepartID nvarchar(64),@RoleID nvarchar(64),@AgentID nvarchar(64),@WareID nvarchar(64),@MDProjectID nvarchar(64)='',@IsIntFactory int=0

select @Err=0,@DepartID=NEWID(),@RoleID=NEWID(),@AgentID=NEWID(),@WareID=NEWID()

--账号
if(@AccountType=1) 
begin
	if exists(select AutoID from UserAccounts where  AccountName = @Account and AccountType in (1,2))
	begin
		set @Result=2
		rollback tran
		return
	end
end
else if(@AccountType=2) --手机
begin
	if exists(select AutoID from UserAccounts where  AccountName = @Account and AccountType in (1,2))
	begin
		set @Result=2
		rollback tran
		return
	end

	set @MobilePhone=@Account
end
else if(@AccountType=3)  --明道网络
begin
	--明道网络已存在
	if exists(select AgentID from Agents where MDProjectID=@CompanyID)
	begin
		set @Result=2
		rollback tran
		return
	end

	if exists(select AutoID from UserAccounts where  AccountName = @Account and AccountType =3 and ProjectID = @CompanyID)
	begin
		set @Result=2
		rollback tran
		return
	end

	set @MDProjectID=@CompanyID
end
else if(@RegisterType=4) --智能工厂
begin
	set @IsIntFactory=1
end

--客户端编码不能重复
while exists(Select AutoID from Clients where ClientCode=@ClientCode)
begin
	set @ClientCode='N'+CONVERT(nvarchar(7), CEILING(RAND()*10000000))
end

--客户端
insert into Clients(ClientID,CompanyName,ContactName,MobilePhone,Status,Industry,CityCode,Address,Description,AgentID,CreateUserID,UserQuantity,EndTime,ClientCode) 
				values(@ClientID,@ClientName,@ContactName,@MobilePhone,1,@Industry,@CityCode,@Address,@Description,@AgentID,@CreateUserID,20,'2016-9-30 23:59:59',@ClientCode )--dateadd(MONTH, 2, GETDATE())

set @Err+=@@error

--直营代理商
insert into Agents(AgentID,CompanyName,Status,RegisterType,IsDefault,MDProjectID,ClientID,UserQuantity,EndTime,IsIntFactory) 
			values(@AgentID,'公司直营',1,@RegisterType,1,@MDProjectID,@ClientID,20,'2016-9-30 23:59:59',@IsIntFactory)

--部门
insert into Department(DepartID,Name,Status,CreateUserID,AgentID,ClientID) values (@DepartID,'系统管理',1,@UserID,@AgentID,@ClientID)
set @Err+=@@error

--角色
insert into Role(RoleID,Name,Status,IsDefault,CreateUserID,AgentID,ClientID) values (@RoleID,'系统管理员',1,1,@UserID,@AgentID,@ClientID)
set @Err+=@@error

insert into Users(UserID,LoginName,BindMobilePhone,LoginPWD,Name,MobilePhone,Email,Allocation,Status,IsDefault,DepartID,RoleID,CreateUserID,MDUserID,MDProjectID,AgentID,ClientID)
				 values(@UserID,'','',@LoginPWD,@ContactName,@MobilePhone,@Email,1,1,1,@DepartID,@RoleID,@UserID,'','',@AgentID,@ClientID)

insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,AgentID,ClientID)
values(@Account,@AccountType,@MDProjectID,@UserID,@AgentID,@ClientID)

--供应商
insert into Providers(ProviderID,Name,Contact,MobileTele,Email,Website,CityCode,Address,Remark,CreateTime,CreateUserID,AgentID,ClientID)
					 values (NEWID(),'公司自营',@ContactName,@MobilePhone,'','','','','',GETDATE(),@UserID,@AgentID,@ClientID)


--系统默认参数
insert into ClientSetting(KeyType,NValue,DValue,IValue,Description,ClientID)
				   values(1,'',0,2,'',@ClientID)
insert into ClientSetting(KeyType,NValue,DValue,IValue,Description,ClientID)
				   values(2,'',1,0,'',@ClientID)

--行业
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'食品、饮料','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'纺织、服装、皮毛','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'木材、家具','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'机械、设备、仪表','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'信息技术业','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'批发和零售贸易','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'金融、保险业','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'传播与文化产业','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'医药、生物制品','',1,GETDATE(),@UserID,@AgentID,@ClientID)
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
values(NEWID(),'交通运输、仓储业','',1,GETDATE(),@UserID,@AgentID,@ClientID)

--客户来源
insert into CustomSource(SourceID,SourceCode,SourceName,IsSystem,IsChoose,Status,CreateUserID,ClientID)
					values(NEWID(),'Source-Manual','手动添加',1,1,1,@UserID,@ClientID)

insert into CustomSource(SourceID,SourceCode,SourceName,IsSystem,IsChoose,Status,CreateUserID,ClientID)
					values(NEWID(),'Source-Activity','活动',1,0,1,@UserID,@ClientID)
					
--客户阶段
insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
values(NEWID(),'新客户',1,1,1,'',@UserID,@ClientID)
insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
values(NEWID(),'机会客户',2,1,2,'',@UserID,@ClientID)
insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
values(NEWID(),'成交客户',3,1,3,'',@UserID,@ClientID)

--客户标签
insert into CustomerColor(ColorID,ColorName,ColorValue,Status,CreateUserID,CreateTime,AgentID,ClientID)
values(1,'普通客户','#3c78d8',0,@UserID,GETDATE(),@AgentID,@ClientID)
insert into CustomerColor(ColorID,ColorName,ColorValue,Status,CreateUserID,CreateTime,AgentID,ClientID)
values(2,'重要客户','#00ff00',0,@UserID,GETDATE(),@AgentID,@ClientID)
insert into CustomerColor(ColorID,ColorName,ColorValue,Status,CreateUserID,CreateTime,AgentID,ClientID)
values(3,'高级客户','#cc0000',0,@UserID,GETDATE(),@AgentID,@ClientID)

--客户等级
insert into ClientMemberLevel(LevelID,Name,IntegFeeMore,DiscountFee,Status,CreateUserID,CreateTime,AgentID,ClientID,Origin)
values(newid(),'普通会员',0,1,1,@UserID,GETDATE(),@AgentID,@ClientID,1)
insert into ClientMemberLevel(LevelID,Name,IntegFeeMore,DiscountFee,Status,CreateUserID,CreateTime,AgentID,ClientID,Origin)
values(newid(),'青铜会员',1000,1,1,@UserID,GETDATE(),@AgentID,@ClientID,2)
insert into ClientMemberLevel(LevelID,Name,IntegFeeMore,DiscountFee,Status,CreateUserID,CreateTime,AgentID,ClientID,Origin)
values(newid(),'白银会员',3000,1,1,@UserID,GETDATE(),@AgentID,@ClientID,3)
insert into ClientMemberLevel(LevelID,Name,IntegFeeMore,DiscountFee,Status,CreateUserID,CreateTime,AgentID,ClientID,Origin)
values(newid(),'黄金会员',7000,1,1,@UserID,GETDATE(),@AgentID,@ClientID,4)

--机会阶段
insert into [OpportunityStage] (StageID,StageName,Probability,Sort,Status,Mark,PID,CreateUserID,ClientID) 
values (NEWID(),'初步沟通',0.2,1,1,1,'',@UserID,@ClientID)
insert into [OpportunityStage] (StageID,StageName,Probability,Sort,Status,Mark,PID,CreateUserID,ClientID)
values (NEWID(),'已拜访',0.4,2,1,0,'',@UserID,@ClientID) 
insert into [OpportunityStage] (StageID,StageName,Probability,Sort,Status,Mark,PID,CreateUserID,ClientID)
values (NEWID(),'达成意向',0.8,3,1,0,'',@UserID,@ClientID) 

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
insert into OrderType(TypeID,TypeCode,TypeName,Status,CreateUserID,ClientID)
values(NEWID(),'Premiums','赠送订单',1,@UserID,@ClientID)

		 
--将客户端作为云销客户插入客户表
declare @DefaultClientID nvarchar(64),@DefaultAgentID nvarchar(64),@SourceID nvarchar(64)

select @DefaultClientID=ClientID,@DefaultAgentID=AgentID from Clients where IsDefault=1

if(@RegisterType=3)
begin
	select @SourceID=SourceID from CustomSource where ClientID=@DefaultClientID and SourceCode='MD'
end
else if(@RegisterType=2)
begin
	select @SourceID=SourceID from CustomSource where ClientID=@DefaultClientID and SourceCode='Self'
end
else if(@RegisterType=4)
begin
	select @SourceID=SourceID from CustomSource where ClientID=@DefaultClientID and SourceCode='ZNGC'
end
else
begin
	select @SourceID=SourceID from CustomSource where ClientID=@DefaultClientID and SourceCode='Source-Manual'
end


insert into Customer(CustomerID,Name,Type,IndustryID,CityCode,Address,MobilePhone,Email,AgentID,ClientID,SourceID,StageStatus)
values(@ClientID,@ClientName,1,@Industry,@CityCode,@Address,@MobilePhone,@Email,@DefaultAgentID,@DefaultClientID ,@SourceID,1)

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