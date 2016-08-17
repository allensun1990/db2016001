Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrderCustomer')
BEGIN
	DROP  Procedure  P_CreateOrderCustomer
END

GO
/***********************************************************
过程名称： P_CreateOrderCustomer
功能描述： 订单客户创建为新客户
参数说明：	 
编写日期： 2016/3/7
程序作者： Allen
调试记录： exec P_CreateOrderCustomer 'a0020b2d-e2b2-4f7f-9774-628759f3513f',
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrderCustomer]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64),
	@Result int output,
	@CustomerID nvarchar(64) output
AS

begin tran

set @CustomerID=''
set @Result=0
	
declare @Status int,@Err int=0,@Name nvarchar(100),@MobileTele nvarchar(20),@AliOrderCode nvarchar(100),@SourceType int=2,
		@DemandCount int=0,@DYCount int=0,@DHCount int=0,@OrderType int,@Address nvarchar(200),@CityCode nvarchar(10),@OrderClientID nvarchar(64)

select @Status=Status,@CustomerID=CustomerID,@MobileTele=MobileTele,@AliOrderCode=AliOrderCode,@OrderType=OrderType,@Name=PersonName,
@CityCode=CityCode, @Address=Address,@OrderClientID=ClientID
from Orders where OrderID=@OrderID 

if(@CustomerID is not null and @CustomerID<>'')
begin
	set @Result=2
	rollback tran
	return
end

if(@MobileTele is null or @MobileTele='')
begin
	set @Result=3
	rollback tran
	return
end

if exists(select AutoID from Customer where MobilePhone=@MobileTele and ClientID=@OrderClientID)
begin
	set @Result=4
	rollback tran
	return
end


set @CustomerID=NEWID()

if(@AliOrderCode is not null and @AliOrderCode<>'')
begin
	set @SourceType=1
end

if(@Status=0)
begin
	set @DemandCount=1
end
else if(@OrderType=1 and @Status<>9)
begin
	set @DYCount=1
end
else if(@OrderType=2 and @Status<>9)
begin
	set @DHCount=1
end

insert into Customer(CustomerID,CustomerPoolID,Name,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,OwnerID,SourceType,
					Status,CreateTime,CreateUserID,ClientID,DemandCount,DYCount,DHCount)
			values( @CustomerID,'',@Name,1,'',0,@CityCode,@Address,@MobileTele,'','','','通过订单联系人创建','',null,@SourceType,1,getdate(),@OperateID,@OrderClientID,@DemandCount,@DYCount,@DHCount)

Update Orders set CustomerID=@CustomerID,CustomerName=@Name where OrderID=@OrderID 

Update Orders set CustomerName=@Name where CustomerID=@CustomerID and OrderID<>@OrderID and CustomerName<>@Name

set @Err+=@@error

if(@Err>0)
begin
	set @CustomerID=''
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end