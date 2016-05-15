Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateContact')
BEGIN
	DROP  Procedure  P_CreateContact
END

GO
/***********************************************************
过程名称： P_CreateContact
功能描述： 新建联系人
参数说明：	 
编写日期： 2015/11/4
程序作者： Allen
调试记录： exec P_CreateContact 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateContact]
@ContactID nvarchar(64),
@CustomerID nvarchar(64),
@Name nvarchar(50),
@CityCode nvarchar(20)='',
@Address nvarchar(500)='',
@MobilePhone nvarchar(50)='',
@OfficePhone nvarchar(50)='',
@Email nvarchar(500)='',
@Jobs nvarchar(200)='',
@Description nvarchar(500)='',
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)
AS
begin tran

declare @Err int=0,@Type int=0,@OwnerID nvarchar(64)

select @OwnerID=OwnerID from Customer where CustomerID=@CustomerID

if not exists(select AutoID from Contact where CustomerID=@CustomerID and Type=1 and Status<>9)
begin
	set @Type=1
end

insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,CityCode,Email,Jobs,Address,Status,OwnerID,CustomerID,CreateUserID,AgentID,ClientID,Description)
	values(@ContactID,@Name,@Type,@MobilePhone,@OfficePhone,@CityCode,@Email,@Jobs,@Address,1,'',@CustomerID,@CreateUserID,@AgentID,@ClientID,@Description)

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

