Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetCustomerByMobilePhone')
BEGIN
	DROP  Procedure  P_GetCustomerByMobilePhone
END

GO
/***********************************************************
过程名称： P_GetCustomerByMobilePhone
功能描述： 通过客户电话获取客户信息
参数说明：	 
编写日期： 2015/11/8
程序作者： Allen
调试记录： exec P_GetCustomerByMobilePhone 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetCustomerByMobilePhone]
	@Name nvarchar(200)='',
	@MobilePhone nvarchar(100),
	@ClientID nvarchar(64)
AS

begin tran
declare @Err int

if( exists( select CustomerID from Customer where ClientID=@ClientID and MobilePhone=@MobilePhone and status<>9 ) )
	select * from Customer where ClientID=@ClientID and MobilePhone=@MobilePhone and status<>9
else
begin
	declare @CustomerID nvarchar(64)=newid()

	insert into Customer(CustomerID,Name,Type,MobilePhone,SourceType,Status,CreateTime,AgentID,ClientID,FirstName)
	values(@CustomerID,@Name,0,@MobilePhone,3,1,getdate(),@ClientID,@ClientID,dbo.fun_getFirstPY(left(@Name,1)) )

	select * from Customer where CustomerID=@CustomerID and ClientID=@ClientID
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




 

