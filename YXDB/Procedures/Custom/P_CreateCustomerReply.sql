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
@ClientID nvarchar(64)='',
@FromReplyID nvarchar(64)='',
@FromReplyUserID nvarchar(64)='',
@FromReplyAgentID nvarchar(64)=''
AS
insert into CustomerReply(ReplyID,GUID,Content,CreateUserID,ClientID,FromReplyID,FromReplyUserID,FromReplyAgentID)
                                values(@ReplyID,@GUID,@Content,@CreateUserID,@ClientID,@FromReplyID,@FromReplyUserID,@FromReplyAgentID)
 

