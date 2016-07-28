Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsterUser')
BEGIN
	DROP  Procedure  P_InsterUser
END

GO
/***********************************************************
过程名称： P_InsterUser
功能描述： 添加用户
参数说明：	 
编写日期： 2015/4/10
程序作者： Allen
调试记录： exec P_InsterUser 
************************************************************/
CREATE PROCEDURE [dbo].[P_InsterUser]
@UserID nvarchar(64),
@AccountType int=1,
@LoginName nvarchar(200)='',
@LoginPWD nvarchar(64)='',
@Name nvarchar(200),
@Mobile nvarchar(64)='',
@Email nvarchar(200)='',
@CityCode nvarchar(10)='',
@Address nvarchar(200)='',
@Jobs nvarchar(200)='',
@RoleID nvarchar(64)='',
@DepartID nvarchar(64)='',
@ParentID nvarchar(64)='',
@AgentID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 账号已存在 3：人数超限
AS

begin tran

set @Result=0

declare @Err int=0,@MaxCount int=0,@Count int

select @MaxCount=UserQuantity from Agents where AgentID=@AgentID

select @Count=count(0) from Users where ClientID=@ClientID and Status=1
--人数超过上限
if(@Count>=@MaxCount)
begin
	set @Result=3
	rollback tran
	return
end

if exists(select AutoID from UserAccounts where AccountName=@LoginName and AccountType =@AccountType)
begin
	set @Result=2
	rollback tran
	return
end

--账号已存在
if(@AccountType < 3 and exists(select AutoID from UserAccounts where AccountName=@LoginName and AccountType in(1,2)))
begin
	set @Result=2
	rollback tran
	return
end

if(@RoleID='')
begin
	select @RoleID=RoleID from Role where AgentID=@AgentID and IsDefault=1
end

set @Err+=@@error


if(@CreateUserID='') set @CreateUserID=@UserID

insert into Users(UserID,LoginName,LoginPWD,Name,MobilePhone,Email,CityCode,Address,Jobs,Allocation,Status,IsDefault,ParentID,RoleID,DepartID,CreateUserID,MDUserID,MDProjectID,AgentID,ClientID)
             values(@UserID,@LoginName,@LoginPWD,@Name,@Mobile,@Email,@CityCode,@Address,@Jobs,1,1,0,@ParentID,@RoleID,@DepartID,@CreateUserID,'','',@AgentID,@ClientID)

insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,AgentID,ClientID)
				 values(@LoginName,@AccountType,'',@UserID,@AgentID,@ClientID)
if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	select * from Users where UserID=@UserID
	set @Result=1
	commit tran
end