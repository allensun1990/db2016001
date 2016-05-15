Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOpportunityStage')
BEGIN
	DROP  Procedure  P_DeleteOpportunityStage
END

GO
/***********************************************************
过程名称： P_DeleteOpportunityStage
功能描述： 删除机会阶段
参数说明：	 
编写日期： 2015/12/5
程序作者： Allen
调试记录： exec P_DeleteOpportunityStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteOpportunityStage]
@StageID nvarchar(64),
@UserID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran

--阶段下有机会
if exists(select AutoID from Orders where StageID=@StageID and Status=0 and ClientID=@ClientID)
begin
	rollback tran
	return
end

declare @Err int=0,@Probability decimal(18,4)=0,@Mark int=0,@Status int=1,@PrevStageID nvarchar(64)

select @Probability=Probability,@Mark=Mark,@Status=Status from OpportunityStage where StageID=@StageID and ClientID=@ClientID
if(@Mark=0 and @Status=1)
begin

	update OpportunityStage set Status=9 where StageID=@StageID and ClientID=@ClientID

	--取得上个机会阶段
	select top 1 @PrevStageID=StageID from OpportunityStage where ClientID=@ClientID and Probability < @Probability and Status<>9

	--更改机会阶段
	update Orders set StageID = @PrevStageID where ClientID=@ClientID and StageID=@StageID

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