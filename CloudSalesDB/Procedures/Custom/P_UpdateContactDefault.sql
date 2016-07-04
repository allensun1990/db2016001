Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateContactDefault')
BEGIN
	DROP  Procedure  P_UpdateContactDefault
END

GO
/***********************************************************
过程名称： P_UpdateContactDefault
功能描述： 联系人设为默认
参数说明：	 
编写日期： 2016/6/30
程序作者： Allen
调试记录： exec P_UpdateContactDefault 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateContactDefault]
@ContactID nvarchar(64),
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS
begin tran

declare @Err int=0,@Type int,@Name nvarchar(100),@CustomerID nvarchar(64)

select @Type=[Type],@CustomerID=CustomerID,@Name=Name from Contact where ContactID=@ContactID
if(@Type<>1)
begin
	Update Contact set [Type]=1 where ContactID=@ContactID
	Update Contact set [Type]=0 where CustomerID=@CustomerID and ContactID<>@ContactID
	Update Customer set ContactName=@Name where CustomerID=@CustomerID
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

 

