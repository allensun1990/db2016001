Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddCustomerReplyAttachment')
BEGIN
	DROP  Procedure  P_AddCustomerReplyAttachment
END

GO
/***********************************************************
过程名称： P_AddCustomerReplyAttachment
功能描述： 添加客户讨论附件
参数说明：	 
编写日期： 2016/6/17
程序作者： MU
调试记录： declare @Result exec P_AddCustomerReplyAttachment @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@OwnerID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_AddCustomerReplyAttachment
@CustomerID nvarchar(64),
@ReplyID nvarchar(64),
@Type int,
@ServerUrl nvarchar(200),
@FilePath nvarchar(200),
@FileName nvarchar(200),
@OriginalName nvarchar(200),
@ThumbnailName nvarchar(200),
@UserID nvarchar(64),
@ClientID nvarchar(64)
as
	declare @AttachmentID nvarchar(64)=newid()
	declare @error int=0
	begin tran

	insert into Attachment(AttachmentID,Type,ServerUrl,FilePath,FileName,OriginalName,ThumbnailName,CreateUserID,ClientID)
	values(@AttachmentID,@Type,@ServerUrl,@FilePath,@FileName,@OriginalName,@ThumbnailName,@UserID,@ClientID)
	set @error+=@@ERROR

	insert into CustomerReplyAttachmentRelation(CustomerID,ReplyID,AttachmentID)
	values(@CustomerID,@ReplyID,@AttachmentID)
	set @error+=@@ERROR


		 





