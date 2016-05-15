Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateCustomerReply')
BEGIN
	DROP  Procedure  P_CreateCustomerReply
END

GO
/***********************************************************
过程名称： P_CreateCustomerReply
功能描述： 新建客户讨论
参数说明：	 
编写日期： 2015/12/24
程序作者： Allen
调试记录： exec P_CreateCustomerReply 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateCustomerReply]
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

insert into CustomerReply(ReplyID,GUID,Content,CreateUserID,AgentID,FromReplyID,FromReplyUserID,FromReplyAgentID)
                                values(@ReplyID,@GUID,@Content,@CreateUserID,@AgentID,@FromReplyID,@FromReplyUserID,@FromReplyAgentID)

update Customer set ReplyTimes=ReplyTimes+1 where CustomerID = @GUID

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

