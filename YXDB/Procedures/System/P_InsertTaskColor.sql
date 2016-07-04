
Use [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertTaskColor')
BEGIN
	DROP  Procedure  P_InsertTaskColor
END

GO
/***********************************************************
过程名称： P_InsertTaskColor
功能描述： 新增客户标签
参数说明：	 
编写日期： 2016/06/12
程序作者： Micahux
调试记录： exec P_InsertTaskColor ''
************************************************************/
Create proc [dbo].[P_InsertTaskColor]
 @ColorName nvarchar(64)='',
 @ColorValue nvarchar(64)='',
 @Status int=0, 
 @AgentID nvarchar(64)='',
 @ClientID nvarchar(64)='',
 @CreateUserID nvarchar(64)='',
 @Result int output
as
set @result=0
if((select COUNT(1) from TaskColor where Status<>9 and  ClientID=@ClientID and AgentID=@AgentID and ColorValue=@ColorValue )>0)
begin
set @result=-1
end
else
begin
	declare @ColorID int
	select @ColorID=isnull(MAX(ColorID),0)+1 from TaskColor where ClientID=@ClientID and AgentID=@AgentID
	insert into TaskColor
	(ColorID,ColorName,ColorValue,Status,AgentID,ClientID,CreateTime,CreateUserID) 
	values
	(@ColorID,@ColorName,@ColorValue,@Status,@AgentID,@ClientID,GETDATE(),@CreateUserID)
	 set @result=@ColorID
 end
GO