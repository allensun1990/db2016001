Use IntFactory
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
@CustomerType int=1,
@AccountID nvarchar(64)='',
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

declare @Err int=0,@StageID nvarchar(64),@AllocationTime datetime=null,@CustomerPoolID nvarchar(64)

--if not exists (select AutoID from CustomerPool where MobilePhone=@MobilePhone)
--begin
--	set @CustomerPoolID=NEWID()
--	Insert into CustomerPool(PoolID,Type,AccountID,Name,MobilePhone,Email)
--	values(@CustomerPoolID,1,@AccountID,@Name,@MobilePhone,@Email)
--end
--else
--begin
--	select @CustomerPoolID=PoolID from CustomerPool where MobilePhone=@MobilePhone
--end

if(@AgentID='')
begin
	select @AgentID=AgentID from Clients where ClientID=@ClientID
end

--if(@OwnerID <> '')
--begin
--	insert into CustomerOwner(CustomerID,UserID,Status,CreateTime,CreateUserID,AgentID,ClientID)
--	values(@CustomerID,@OwnerID,1,getdate(),@CreateUserID,@AgentID,@ClientID)

--	set @AllocationTime=getdate()

--	set @Err+=@@error
--end

if not exists (select AutoID from Customer where MobilePhone=@MobilePhone and ClientID=@ClientID)
begin
	insert into Customer(CustomerID,CustomerPoolID,Name,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,ActivityID,OwnerID,SourceType,
						StageID,Status,AllocationTime,OrderTime,CreateTime,CreateUserID,AgentID,ClientID)
	values(@CustomerID,@CustomerPoolID,@Name,@Type,@IndustryID,@Extent,@CityCode,@Address,@MobilePhone,@OfficePhone,@Email,@Jobs,@Description,@SourceID,@ActivityID,@OwnerID,3,
						@StageID,1,@AllocationTime,null,getdate(),@CreateUserID,@AgentID,@ClientID)
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

 

