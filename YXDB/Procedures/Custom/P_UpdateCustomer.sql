﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCustomer')
BEGIN
	DROP  Procedure  P_UpdateCustomer
END

GO
/***********************************************************
过程名称： P_UpdateCustomer
功能描述： 编辑客户
参数说明：	 
编写日期： 2015/11/9
程序作者： Allen
调试记录： exec P_UpdateCustomer 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateCustomer]
@CustomerID nvarchar(64),
@Name nvarchar(50),
@Type int=0,
@IndustryID nvarchar(64)='',
@Extent int=0,
@CityCode nvarchar(20)='',
@Address nvarchar(500)='',
@MobilePhone nvarchar(50)='',
@OfficePhone nvarchar(50)='',
@Email nvarchar(500)='',
@Jobs nvarchar(200)='',
@Description nvarchar(500)='',
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)
AS
begin tran
declare @Err int=0

--客户名称有变更
if not exists(select AutoID from Customer where CustomerID=@CustomerID and Name=@Name)
begin
	Update Orders set CustomerName=@Name where CustomerID=@CustomerID 
end

Update Customer set Name=@Name,Type=@Type,IndustryID=@IndustryID,Extent=@Extent,CityCode=@CityCode,Address=@Address,MobilePhone=@MobilePhone,OfficePhone=@OfficePhone,
		Email=@Email,Jobs=@Jobs,Description=@Description,FirstName=dbo.fun_getFirstPY(left(@Name,1)) where CustomerID=@CustomerID and ClientID=@ClientID

set @Err+=@@error
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

