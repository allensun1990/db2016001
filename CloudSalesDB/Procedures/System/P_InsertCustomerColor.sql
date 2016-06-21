
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertCustomerColor')
BEGIN
	DROP  Procedure  P_InsertCustomerColor
END

GO
/***********************************************************
过程名称： P_InsertCustomSource
功能描述： 添加客户来源
参数说明：	 
编写日期： 2016/6/10
程序作者： mi
调试记录： exec P_InsertCustomerColor 
************************************************************/
create proc P_InsertCustomerColor
 @ColorName nvarchar(64)='',
 @ColorValue nvarchar(64)='',
 @Status int=0, 
 @AgentID nvarchar(64)='',
 @ClientID nvarchar(64)='',
 @CreateUserID nvarchar(64)='',
 @result int output
as
set @result=0
declare @ColorID int
select @ColorID=isnull(MAX(ColorID),0)+1 from CustomerColor where ClientID=@ClientID and AgentID=@AgentID
insert into CustomerColor(ColorID,ColorName,ColorValue,Status,AgentID,ClientID,CreateTime,CreateUserID) 
values(@ColorID,@ColorName,@ColorValue,@Status,@AgentID,@ClientID,GETDATE(),@CreateUserID)

set @result=@ColorID