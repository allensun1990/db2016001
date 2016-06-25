Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrder')
BEGIN
	DROP  Procedure  P_CreateOrder
END

GO
/***********************************************************
过程名称： P_CreateOrder
功能描述： 创建订单
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_CreateOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrder]
@OrderID nvarchar(64),
@OrderCode nvarchar(20),
@CustomerID nvarchar(64)='',
@TypeID nvarchar(64)='',
@UserID nvarchar(64),
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS

begin tran

declare @Err int=0,@PersonName nvarchar(50),@MobileTele nvarchar(20),@CityCode nvarchar(20),@Address nvarchar(200),@OwnerID nvarchar(64),@Type int

select @PersonName=Name,@MobileTele=MobilePhone,@CityCode=CityCode,@Address=Address,@OwnerID=OwnerID,@Type=Type from Customer where CustomerID=@CustomerID
if(@Type=1)
begin	
	select @PersonName=Name,@MobileTele=MobilePhone,@CityCode=CityCode,@Address=Address from Contact where CustomerID=@CustomerID and Status<>9 Order By [Type] desc
end

if(@OwnerID is null or @OwnerID='')
begin
	set @OwnerID=@UserID
end

if exists (select AutoID from Orders where OrderCode=@OrderCode and ClientID=@ClientID)
begin
	set @OrderCode=@OrderCode+'1'
end

insert into Orders(OrderID,OrderCode,Status,CustomerID,PersonName,MobileTele,CityCode,Address,OwnerID,CreateUserID,AgentID,ClientID,TypeID)
		values (@OrderID,@OrderCode,1,@CustomerID,@PersonName,@MobileTele,@CityCode,@Address,@OwnerID,@UserID,@AgentID,@ClientID,@TypeID)

update Customer set OrderCount=OrderCount+1 where CustomerID=@CustomerID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end