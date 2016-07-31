
Use [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertCustomerColor')
BEGIN
	DROP  Procedure  P_InsertCustomerColor
END

GO
/***********************************************************
过程名称： P_InsertCustomerColor
功能描述： 新增客户标签
参数说明：	 
编写日期： 2016/06/12
程序作者： Micahux
调试记录： exec P_InsertCustomerColor ''
************************************************************/
Create proc [dbo].[P_InsertCustomerColor]
 @ColorName nvarchar(64)='',
 @ColorValue nvarchar(64)='',
 @Status int=0, 
 @ClientID nvarchar(64)='',
 @CreateUserID nvarchar(64)='',
 @Result int output
as
set @result=0
if((select COUNT(1) from CustomerColor where Status<>9 and  ClientID=@ClientID and ColorValue=@ColorValue )>0)
begin
	set @result=-1
end
else
begin
	declare @ColorID int
	select @ColorID=isnull(MAX(ColorID),0)+1 from CustomerColor where ClientID=@ClientID 
	insert into CustomerColor(ColorID,ColorName,ColorValue,Status,ClientID,CreateTime,CreateUserID) 
	values(@ColorID,@ColorName,@ColorValue,@Status,@ClientID,GETDATE(),@CreateUserID)
	 set @result=@ColorID
 end
GO