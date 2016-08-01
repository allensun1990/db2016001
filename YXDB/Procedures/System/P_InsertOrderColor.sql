
Use [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertOrderColor')
BEGIN
	DROP  Procedure  P_InsertOrderColor
END

GO
/***********************************************************
过程名称： P_InsertOrderColor
功能描述： 新增客户标签
参数说明：	 
编写日期： 2016/06/12
程序作者： Micahux
调试记录： exec P_InsertOrderColor ''
************************************************************/
Create proc [dbo].[P_InsertOrderColor]
 @ColorName nvarchar(64)='',
 @ColorValue nvarchar(64)='',
 @Status int=0, 
 @ClientID nvarchar(64)='',
 @CreateUserID nvarchar(64)='',
 @Result int output
as
set @result=0
if((select COUNT(1) from OrderColor where Status<>9 and  ClientID=@ClientID and  ColorValue=@ColorValue )>0)
begin
set @result=-1
end
else
begin
	declare @ColorID int
	select @ColorID=isnull(MAX(ColorID),0)+1 from OrderColor where ClientID=@ClientID 
	insert into OrderColor
	(ColorID,ColorName,ColorValue,Status,ClientID,CreateTime,CreateUserID) 
	values
	(@ColorID,@ColorName,@ColorValue,@Status,@ClientID,GETDATE(),@CreateUserID)
	 set @result=@ColorID
 end
GO