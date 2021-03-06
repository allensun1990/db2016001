﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTaskReplys')
BEGIN
	DROP  Procedure  P_GetTaskReplys
END

GO
/***********************************************************
过程名称： P_GetTaskReplys
功能描述： 获取任务讨论列表
参数说明：	 
编写日期： 2016/6/16
程序作者： MU
调试记录： 
declare @TotalCount int=0
declare @PageCount int=0
exec P_GetTaskReplys @OrderID='6dd96291-f34e-440e-94c7-1a37c388eb46',@StageID='12a65128-0fec-4544-927f-a2e6c8148511',
@TotalCount=@TotalCount out,@PageCount=@PageCount out
************************************************************/
CREATE PROCEDURE [dbo].P_GetTaskReplys
@TaskID nvarchar(64),
@PageSize int=20,
@PageIndex int=1,
@TotalCount int output,
@PageCount int output
as
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)

	declare @tmp table(rowid nvarchar(50) default('0') null ,ReplyID nvarchar(64))
	declare @total int,@page int

	set @tableName='TaskReply'
	set @columns='ReplyID'
	set @key='ReplyID'
	set @orderColumn='createtime desc'
	set @condition=' [guid]='''+@TaskID+''' and status<>9'

	insert into @tmp exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@PageSize,@PageIndex,@total out,@page out,0 

	select @totalCount=@total,@pageCount =@page

	select * from TaskReply where ReplyID in( select ReplyID from  @tmp ) order by createtime desc

	select a.*,t.ReplyID as Guid from TaskReplyAttachmentRelation t left join Attachment a on t.AttachmentID=a.AttachmentID
	where t.status<>9 and t.ReplyID in ( select ReplyID from  @tmp )
		 





