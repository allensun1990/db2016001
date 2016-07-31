Use IntFactory
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
@StageID nvarchar(64)='',
@Mark int=1,
@Content nvarchar(4000),
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@FromReplyID nvarchar(64)='',
@FromReplyUserID nvarchar(64)='',
@FromReplyAgentID nvarchar(64)=''
AS
begin tran

declare @Err int=0

insert into OrderReply(ReplyID,GUID,StageID,Mark,Content,CreateUserID,ClientID,FromReplyID,FromReplyUserID,FromReplyAgentID)
                                values(@ReplyID,@GUID,@StageID,@Mark,@Content,@CreateUserID,@ClientID,@FromReplyID,@FromReplyUserID,@FromReplyAgentID)


if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

