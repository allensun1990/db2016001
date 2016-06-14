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
insert into CustomerColor
(ColorID,ColorName,ColorValue,Status,AgentID,ClientID,CreateTime,CreateUserID) 
values
(@ColorID,@ColorName,@ColorValue,@Status,@AgentID,@ClientID,GETDATE(),@CreateUserID)

 set @result=@ColorID