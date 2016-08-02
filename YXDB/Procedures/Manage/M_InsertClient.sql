Use IntFactory
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
程序作者： 
	修改： 2016/7/28   Allen
调试记录： exec M_InsertClient 
************************************************************/
CREATE PROCEDURE [dbo].[M_InsertClient]
@ClientID nvarchar(64),
@ClientCode nvarchar(20),
@RegisterType int=0,
@AccountType int =0,
@Account nvarchar(200),
@CompanyName nvarchar(200)='',
@MobilePhone nvarchar(64)='',
@Industry nvarchar(64)='',
@CityCode nvarchar(10)='',
@Address nvarchar(200)='',
@Description nvarchar(200)='',
@ContactName nvarchar(50),
@LoginPWD nvarchar(64)='',
@Email nvarchar(200)='',
@CompanyID nvarchar(64)='',
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

declare @Err int ,@DepartID nvarchar(64),@RoleID nvarchar(64),@WareID nvarchar(64),@AliMemberID nvarchar(200),@LoginName nvarchar(100)

select @Err=0,@DepartID=NEWID(),@RoleID=NEWID(),@WareID=NEWID()

if exists(select AutoID from UserAccounts where  AccountName = @Account and AccountType =@AccountType)
begin
	set @Result=2
	rollback tran
	return
end


--账号
if(@AccountType=1) 
begin
	if exists(select AutoID from UserAccounts where  AccountName = @Account and AccountType in (1,2))
	begin
		set @Result=2
		rollback tran
		return
	end
	set @LoginName=@Account
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


if(@AccountType=3)
begin
	set @AliMemberID=@Account
end

--客户端编码不能重复
while exists(Select AutoID from Clients where ClientCode=@ClientCode)
begin
	set @ClientCode='N'+CONVERT(nvarchar(5), CEILING(RAND()*100000))
end

--客户端
insert into Clients(ClientID,ClientCode,CompanyName,ContactName,MobilePhone,Status,GuideStep,Industry,CityCode,Address,Description,CreateUserID,UserQuantity,EndTime,AliMemberID,RegisterType) 
				values(@ClientID,@ClientCode,@CompanyName,@ContactName,@MobilePhone,1,1,@Industry,@CityCode,@Address,@Description,@CreateUserID,20,dateadd(MONTH, 1, GETDATE()),@AliMemberID,@RegisterType)

set @Err+=@@error


--部门
insert into Department(DepartID,Name,Status,CreateUserID,ClientID) values (@DepartID,'系统管理',1,@UserID,@ClientID)
set @Err+=@@error

--角色
insert into Role(RoleID,Name,Status,IsDefault,CreateUserID,ClientID) values (@RoleID,'系统管理员',1,1,@UserID,@ClientID)

set @Err+=@@error

insert into Users(UserID,LoginName,LoginPWD,Name,MobilePhone,Email,Allocation,Status,IsDefault,DepartID,RoleID,CreateUserID,ClientID)
             values(@UserID,@LoginName,@LoginPWD,@ContactName,@MobilePhone,@Email,1,1,1,@DepartID,@RoleID,@UserID,@ClientID)

insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
values(@Account,@AccountType,'',@UserID,@ClientID)

--部门关系
insert into UserDepart(UserID,DepartID,CreateUserID,ClientID) values(@UserID,@DepartID,@UserID,@ClientID)  
set @Err+=@@error
   
--角色关系
insert into UserRole(UserID,RoleID,CreateUserID,ClientID) values(@UserID,@RoleID,@UserID,@ClientID) 
set @Err+=@@error

--仓库
insert into WareHouse(WareID,WareCode,Name,Status,CreateUserID,ClientID)
values(@WareID,'Ware001','主仓库',1,@UserID,@ClientID)

insert into DepotSeat(DepotID,DepotCode,WareID,Name,Status,CreateUserID,ClientID)
values(NEWID(),'Depot001',@WareID,'主货位',1,@UserID,@ClientID)


--供应商
insert into Providers(ProviderID,Name,Contact,MobileTele,Email,Website,CityCode,Address,Remark,CreateTime,CreateUserID,ClientID)
			 values (NEWID(),'公司直营',@CompanyName,@MobilePhone,@Email,'',@CityCode,@Address,'',GETDATE(),@UserID,@ClientID)

--初始化客户、订单、任务的标签颜色
create table #color(ColorValue varchar(50) ,ColorName varchar(50),ColorID int)
insert  into #color values('#3c78d8','普通',1) 
insert  into #color values('#00ff00','重要',2)
insert  into #color values('#cc0000','紧急',3)  

insert into CustomerColor (ColorID,ColorName,ColorValue,Status,CreateUserID,CreateTime,UpdateTime,UpdateUserID,ClientID)
select b.ColorID,b.ColorName, b.ColorValue,0,'',GETDATE(),null,null,a.ClientID 
from Clients a join #color b  on  ClientID=@ClientID

insert into OrderColor (ColorID,ColorName,ColorValue,Status,CreateUserID,CreateTime,UpdateTime,UpdateUserID,ClientID)
select b.ColorID,b.ColorName, b.ColorValue,0,'',GETDATE(),null,null,a.ClientID 
from Clients a join #color b  on  ClientID=@ClientID

insert into TaskColor (ColorID,ColorName,ColorValue,Status,CreateUserID,CreateTime,UpdateTime,UpdateUserID,ClientID)
select b.ColorID,b.ColorName, b.ColorValue,0,'',GETDATE(),null,null,a.ClientID 
from Clients a join #color b  on  ClientID=@ClientID

drop table #color

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