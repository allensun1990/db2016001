Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrderReply')
BEGIN
	DROP  Procedure  P_CreateOrderReply
END

GO
/***********************************************************
过程名称： P_CreateOrderReply
功能描述： 新建机会/订单讨论
参数说明：	 
编写日期： 2015/12/24
程序作者： Allen
调试记录： exec P_CreateOrderReply 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrderReply]
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

insert into OrderReply(ReplyID,GUID,Content,CreateUserID,AgentID,FromReplyID,FromReplyUserID,FromReplyAgentID)
                                values(@ReplyID,@GUID,@Content,@CreateUserID,@AgentID,@FromReplyID,@FromReplyUserID,@FromReplyAgentID)

update Orders set ReplyTimes=ReplyTimes+1 where OrderID = @GUID

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

