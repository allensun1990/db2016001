Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderCustomer')
BEGIN
	DROP  Procedure  P_UpdateOrderCustomer
END

GO
/***********************************************************
过程名称： P_UpdateOrderCustomer
功能描述： 绑定客户
参数说明：	 
编写日期： 2016/3/11
程序作者： Allen
调试记录： exec P_UpdateOrderCustomer 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderCustomer]
	@OrderID nvarchar(64),
	@CustomerID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int=-1,@OrderType int,@Name nvarchar(50),@MobilePhone nvarchar(20),@CityCode nvarchar(10),@Address nvarchar(500),@OldCustomerID nvarchar(64)

select @Status=Status,@OrderType=OrderType,@OldCustomerID=CustomerID from Orders where OrderID=@OrderID and ClientID=@ClientID 

select @Name=Name,@MobilePhone=MobilePhone,@CityCode=CityCode,@Address=Address from Customer where CustomerID=@CustomerID

if(@Status<>0)
begin
	rollback tran
	return
end

Update Orders set CustomerID=@CustomerID,PersonName=@Name,MobileTele=@MobilePhone,CityCode=@CityCode,Address=@Address where OrderID=@OrderID

--处理客户需求单数
Update Customer set DemandCount=DemandCount+1 where CustomerID=@CustomerID

Update Customer set DemandCount=DemandCount-1 where CustomerID=@OldCustomerID and DemandCount>0

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

