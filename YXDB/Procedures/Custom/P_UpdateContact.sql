Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateContact')
BEGIN
	DROP  Procedure  P_UpdateContact
END

GO
/***********************************************************
过程名称： P_UpdateContact
功能描述： 编辑联系人
参数说明：	 
编写日期： 2015/11/10
程序作者： Allen
调试记录： exec P_UpdateContact 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateContact]
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

declare @Err int=0


Update Contact set Name=@Name,CityCode=@CityCode,Address=@Address,MobilePhone=@MobilePhone,OfficePhone=@OfficePhone,
					Email=@Email,Jobs=@Jobs,Description=@Description where ContactID=@ContactID

set @Err+=@@error
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

