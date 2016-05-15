Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateUserParentID')
BEGIN
	DROP  Procedure  P_UpdateUserParentID
END

GO
/***********************************************************
过程名称： P_UpdateUserParentID
功能描述： 编辑员工上级
参数说明：	 
编写日期： 2015/10/23
程序作者： Allen
调试记录： exec P_UpdateUserParentID 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateUserParentID]
@UserID nvarchar(64),
@ParentID nvarchar(64),
@AgentID nvarchar(64)
AS

begin tran

declare @Err int =0 

--只能有一个顶点
if(@ParentID='6666666666' and exists(select AutoID from Users where ParentID='6666666666' and AgentID=@AgentID))
begin
	rollback tran
	return
end

Update Users set ParentID= @ParentID where UserID=@UserID and AgentID=@AgentID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end