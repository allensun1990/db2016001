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
@ClientID nvarchar(64)
AS
declare @CustomerPoolID nvarchar(64)

if not exists (select AutoID from Customer where MobilePhone=@MobilePhone and ClientID=@ClientID)
begin
	insert into Customer(CustomerID,CustomerPoolID,Name,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,OwnerID,SourceType,
						Status,CreateTime,CreateUserID,ClientID,FirstName)
	values(@CustomerID,@CustomerPoolID,@Name,@Type,@IndustryID,@Extent,@CityCode,@Address,@MobilePhone,@OfficePhone,@Email,@Jobs,@Description,@SourceID,@OwnerID,3,
						1,getdate(),@CreateUserID,@ClientID,dbo.fun_getFirstPY(left(@Name,1)) )
end

 

