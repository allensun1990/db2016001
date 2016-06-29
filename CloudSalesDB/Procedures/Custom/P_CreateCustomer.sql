Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateCustomer')
BEGIN
	DROP  Procedure  P_CreateCustomer
END

GO
/***********************************************************
过程名称： P_CreateCustomer
功能描述： 新建客户
参数说明：	 
编写日期： 2015/11/4
程序作者： Allen
调试记录： exec P_CreateCustomer 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateCustomer]
@CustomerID nvarchar(64),
@Name nvarchar(50),
@Type int=0,
@SourceID nvarchar(64)='',
@ActivityID nvarchar(64)='',
@IndustryID nvarchar(64)='',
@Extent int=0,
@CityCode nvarchar(20)='',
@Address nvarchar(500)='',
@ContactName nvarchar(200)='',
@MobilePhone nvarchar(50)='',
@OfficePhone nvarchar(50)='',
@Email nvarchar(500)='',
@Jobs nvarchar(200)='',
@Description nvarchar(500)='',
@OwnerID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)
AS
begin tran

declare @Err int=0,@StageID nvarchar(64),@AllocationTime datetime=null

--新客户阶段
--select @StageID=StageID from  CustomStage where ClientID=@ClientID and Mark=1

if(@AgentID='')
begin
	select @AgentID=AgentID from Clients where ClientID=@ClientID
end

if(@OwnerID <>'')
begin
	insert into CustomerOwner(CustomerID,UserID,Status,CreateTime,CreateUserID,AgentID,ClientID)
	values(@CustomerID,@OwnerID,1,getdate(),@CreateUserID,@AgentID,@ClientID)

	set @AllocationTime=getdate()

	set @Err+=@@error
end

insert into Customer(CustomerID,Name,ContactName,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,ActivityID,
					StageID,OwnerID,Status,AllocationTime,OrderTime,CreateTime,CreateUserID,AgentID,ClientID)
values(@CustomerID,@Name,@ContactName,@Type,@IndustryID,@Extent,@CityCode,@Address,@MobilePhone,@OfficePhone,@Email,@Jobs,@Description,@SourceID,@ActivityID,
					@StageID,@OwnerID,1,@AllocationTime,null,getdate(),@CreateUserID,@AgentID,@ClientID)

set @Err+=@@error

if(@Type=1 and @ContactName<>'')
begin
	insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,Email,Jobs,Status,OwnerID,CustomerID,CreateUserID,AgentID,ClientID)
	values(NEWID(),@ContactName,1,@MobilePhone,@OfficePhone,@Email,@Jobs,1,@OwnerID,@CustomerID,@CreateUserID,@AgentID,@ClientID)
end

if(@ActivityID<>'')
begin
	update Activity set CustomerQuantity=CustomerQuantity+1 where ActivityID=@ActivityID
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

