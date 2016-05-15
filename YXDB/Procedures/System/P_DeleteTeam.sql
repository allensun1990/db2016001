Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteTeam')
BEGIN
	DROP  Procedure  P_DeleteTeam
END

GO
/***********************************************************
过程名称： P_DeleteTeam
功能描述： 删除团队
参数说明：	 
编写日期： 2015/10/30
程序作者： Allen
调试记录： exec P_DeleteTeam 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteTeam]
@TeamID nvarchar(64),
@UserID nvarchar(64)='',
@AgentID nvarchar(64)
AS

begin tran

declare @Err int=0

Update Teams set Status=9 where TeamID=@TeamID 

Update TeamUser set Status=9,UpdateTime=getdate() where TeamID=@TeamID  and Status=1
set @Err+=@@error

Update Users set TeamID='' where TeamID=@TeamID
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end