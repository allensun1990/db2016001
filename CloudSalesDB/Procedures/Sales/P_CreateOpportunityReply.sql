Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOpportunityReply')
BEGIN
	DROP  Procedure  P_CreateOpportunityReply
END

GO
/***********************************************************
过程名称： P_CreateOpportunityReply
功能描述： 新建机会讨论
参数说明：	 
编写日期： 2016/5/4
程序作者： Allen
调试记录： exec P_CreateOpportunityReply 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOpportunityReply]
@ReplyID nvarchar(64),
@GUID nvarchar(64),
@Content nvarchar(4000),
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@FromReplyID nvarchar(64)='',
@FromReplyUserID nvarchar(64)='',
@FromReplyAgentID nvarchar(64)=''
AS
begin tran

declare @Err int=0

insert into OpportunityReply(ReplyID,GUID,Content,CreateUserID,AgentID,FromReplyID,FromReplyUserID,FromReplyAgentID)
                                values(@ReplyID,@GUID,@Content,@CreateUserID,@AgentID,@FromReplyID,@FromReplyUserID,@FromReplyAgentID)

update Opportunity set ReplyTimes=ReplyTimes+1 where OpportunityID = @GUID

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

