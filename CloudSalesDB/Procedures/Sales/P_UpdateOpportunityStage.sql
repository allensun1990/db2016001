Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOpportunityStage')
BEGIN
	DROP  Procedure  P_UpdateOpportunityStage
END

GO
/***********************************************************
过程名称： P_UpdateOpportunityStage
功能描述： 修改机会阶段
参数说明：	 
编写日期： 2015/12/6
程序作者： Allen
调试记录： exec P_UpdateOpportunityStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOpportunityStage]
	@OpportunityID nvarchar(64)='',
	@StageID nvarchar(64)='',
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@OldStages nvarchar(64)


select @OldStages=StageID from Opportunity where OpportunityID=@OpportunityID 

if(@OldStages<>@StageID)
begin
	update Opportunity set StageID=@StageID where OpportunityID=@OpportunityID and Status=1
end

set @Err+=@@error

--处理记录
insert into OpportunityStageLog(OpportunityID,StageID,OldStageID,Status,Type,CreateUserID,AgentID,ClientID)
		values(@OpportunityID,@StageID,@OldStages,1,1,@OperateID,@AgentID,@ClientID)

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 

