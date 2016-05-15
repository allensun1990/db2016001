Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ChangeUsersParentID')
BEGIN
	DROP  Procedure  P_ChangeUsersParentID
END

GO
/***********************************************************
过程名称： P_ChangeUsersParentID
功能描述： 替换员工上级
参数说明：	 
编写日期： 2015/10/24
程序作者： Allen
调试记录： exec P_ChangeUsersParentID 
************************************************************/
CREATE PROCEDURE [dbo].[P_ChangeUsersParentID]
@UserID nvarchar(64),
@OldUserID nvarchar(64),
@AgentID nvarchar(64)
AS

begin tran

declare @Err int =0 ,@OldParentID nvarchar(64)

--被替换员工上级ID
select @OldParentID=ParentID from Users where UserID = @OldUserID and AgentID=@AgentID
 
Update Users set ParentID=@OldParentID where UserID=@UserID and AgentID=@AgentID

--被替换员工下级改到员工下面
Update Users set ParentID=@UserID where ParentID=@OldUserID

--制空被替换员工上级
Update Users set ParentID= '' where UserID=@OldUserID and AgentID=@AgentID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end