Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateTaskReply')
BEGIN
	DROP  Procedure  P_CreateTaskReply
END

GO
/***********************************************************
过程名称： P_CreateTaskReply
功能描述： 新建任务讨论
参数说明：	 
编写日期： 2016/8/12
程序作者： Allen
调试记录： exec P_CreateTaskReply 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateTaskReply]
@ReplyID nvarchar(64),
@GUID nvarchar(64),
@Content nvarchar(4000),
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@FromReplyID nvarchar(64)='',
@FromReplyUserID nvarchar(64)='',
@FromReplyAgentID nvarchar(64)=''
AS
insert into TaskReply(ReplyID,GUID,Content,CreateUserID,ClientID,FromReplyID,FromReplyUserID,FromReplyAgentID,status)
values(@ReplyID,@GUID,@Content,@CreateUserID,@ClientID,@FromReplyID,@FromReplyUserID,@FromReplyAgentID,1)


 

