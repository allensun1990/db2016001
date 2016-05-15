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
	@CustomerID nvarchar(64) output
AS

begin tran

set @CustomerID=''
	
declare @Status int,@Err int=0,@MobileTele nvarchar(20),@AliOrderCode nvarchar(100),@SourceType int=2

select @Status=Status,@CustomerID=CustomerID,@MobileTele=MobileTele,@AliOrderCode=AliOrderCode from Orders where OrderID=@OrderID and ClientID=@ClientID

if(@CustomerID is not null and @CustomerID<>'')
begin
	rollback tran
	return
end

if not exists(select AutoID from Customer where MobilePhone=@MobileTele and ClientID=@ClientID)
begin
	set @CustomerID=NEWID()

	if(@AliOrderCode is not null and @AliOrderCode<>'')
	begin
		set @SourceType=1
	end

	insert into Customer(CustomerID,CustomerPoolID,Name,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,ActivityID,OwnerID,SourceType,
							StageID,Status,AllocationTime,OrderTime,CreateTime,CreateUserID,AgentID,ClientID)
				select @CustomerID,'',PersonName,1,'',0,CityCode,Address,MobileTele,'','','','通过订单联系人创建','','',OwnerID,@SourceType,'',1,getdate(),getdate(),getdate(),@OperateID,AgentID,ClientID
				from Orders where OrderID=@OrderID and ClientID=@ClientID

	Update Orders set CustomerID=@CustomerID where OrderID=@OrderID and ClientID=@ClientID

	set @Err+=@@error
end
if(@Err>0)
begin
	set @CustomerID=''
	rollback tran
end 
else
begin
	commit tran
end