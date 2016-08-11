 Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetReplysByType')
BEGIN
	DROP  Procedure  P_GetReplysByType
END

GO
/***********************************************************
过程名称： P_GetReplysByType
功能描述： 根据获取类型讨论
参数说明：	 
编写日期： 2016/08/11
程序作者： Michaux
调试记录： exec P_GetReplysByType 
************************************************************/
Create  proc  P_GetReplysByType
@ID varchar(64),
@Type int,
@AgentID varchar(64), 
@pageSize int,
@pageIndex int,
@totalCount int output,
@pageCount int output
as
declare @tableName nvarchar(4000),
	@sql nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)

	declare @tmp table(rowid nvarchar(50) default('0') null ,ReplyID nvarchar(64))
	declare @total int,@page int

	set @tableName=case @Type when 1 then 'CustomerReply' when 2 then 'OrderReply' when 3 then 'ActivityReply'  else 'OrderReply' end
	set @columns='ReplyID'
	set @key='ReplyID'
	set @orderColumn='createtime desc'
	set @condition='status<>9 and AgentID='''+@AgentID+''' and  guid='''+@ID+''''


	insert into @tmp exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@PageSize,@PageIndex,@total out,@page out,0 

	select @totalCount=@total,@pageCount =@page

	set @sql='select * from '+@tableName+' where ReplyID in( select ReplyID from  @tmp ) order by createtime desc'
	exec(@sql)
	select * from Attachment  where  ReplyID in ( select ReplyID from  @tmp )
 