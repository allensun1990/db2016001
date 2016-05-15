Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateUserTeamID')
BEGIN
	DROP  Procedure  P_UpdateUserTeamID
END

GO
/***********************************************************
过程名称： P_UpdateUserTeamID
功能描述： 编辑员工团队ID
参数说明：	 
编写日期： 2015/10/30
程序作者： Allen
调试记录： exec P_UpdateUserTeamID 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateUserTeamID]
@UserID nvarchar(64),
@TeamID nvarchar(64),
@AgentID nvarchar(64),
@OperateID nvarchar(64)=''
AS

begin tran

declare @Err int =0 

--团队添加成员
if(@TeamID<>'')
begin
	if exists(select AutoID from Users where TeamID is not null and TeamID<> '' and UserID=@UserID)
	begin
		rollback tran
		return
	end

	Update Users set TeamID= @TeamID where UserID=@UserID and AgentID=@AgentID

	insert into TeamUser(TeamID,UserID,Status,CreateTime,CreateUserID,ClientID)
	values(@TeamID,@UserID,1,getdate(),@OperateID,@AgentID)

	set @Err+=@@error
end
else --移出成员
begin
	Update Users set TeamID= '' where UserID=@UserID and AgentID=@AgentID

	update TeamUser set Status=9 ,UpdateTime =getdate() where UserID=@UserID 

	set @Err+=@@error
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end