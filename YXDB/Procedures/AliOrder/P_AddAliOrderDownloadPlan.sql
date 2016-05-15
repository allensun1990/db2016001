Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddAliOrderDownloadPlan')
BEGIN
	DROP  Procedure  P_AddAliOrderDownloadPlan
END

GO
/***********************************************************
过程名称： P_AddAliOrderDownloadPlan
功能描述： 新增阿里订单下载计划
参数说明：	 
编写日期： 2016/3/23
程序作者： MU
调试记录： exec P_AddAliOrderDownloadPlan 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddAliOrderDownloadPlan]
@UserID nvarchar(64),
@MemberID nvarchar(64),
@Token nvarchar(64),
@RefreshToken nvarchar(64),
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS
begin tran

declare @Err int=0
if(not exists(select MemberID from AliOrderDownloadPlan where ClientID=@ClientID))
begin
	insert into AliOrderDownloadPlan(PlanID,UserID,MemberID,Token,RefreshToken,FentSuccessEndTime,BulkSuccessEndTime,AgentID,ClientID,Status,CreateTime,UpdateTime,CreateUserID)
	values (NEWID(),@UserID,@MemberID,@Token,@RefreshToken,GETDATE(),GETDATE(),@AgentID,@ClientID,1,GETDATE(),GETDATE(),@UserID)
	set @Err+=@@ERROR
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

