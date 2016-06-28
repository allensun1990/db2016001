Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetActivitys')
BEGIN
	DROP  Procedure  P_GetActivitys
END

GO
/***********************************************************
过程名称： P_GetActivitys
功能描述： 获取活动列表
参数说明：	 
编写日期： 2015/10/14
程序作者： Allen
调试记录： exec P_GetActivitys 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetActivitys]
	@UserID nvarchar(64)='',
	@Stage int=-1,
	@keyWords nvarchar(4000),
	@BeginTime nvarchar(200),
	@EndTime nvarchar(200),
	@OrderBy nvarchar(1000)='',
	@pageSize int,
	@pageIndex int,
	@FilterType int=0,
	@totalCount int output ,
	@pageCount int output,
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@isAsc int

	select @tableName='Activity',@columns='*',@key='AutoID',@isAsc=0
	set @condition=' ClientID='''+@ClientID+''' and Status<>9 '

	if(@UserID<>'')
	begin
		if(@FilterType=1)
			set @condition +=' and OwnerID = '''+@UserID+''''
		else if(@FilterType=2)
			set @condition +=' and MemberID like ''%'+@UserID+'%'' '
	    else
			set @condition +=' and ( OwnerID = '''+@UserID+'''' +' or MemberID like ''%'+@UserID+'%'' )'
	end

	if(@AgentID<>'')
	begin
		set @condition +=' and AgentID = '''+@AgentID+''''
	end

	--已结束
	if(@Stage=1)
	begin
		set @condition +=' and EndTime < getdate() '
	end
	else if(@Stage=2) --进行中
	begin
		set @condition +=' and EndTime > getdate() and BeginTime<= getdate() '
	end
	else if(@Stage=3) --未开始
	begin
		set @condition +=' and BeginTime > getdate() '
	end

	if(@BeginTime<>'')
		set @condition +=' and BeginTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and EndTime <=  '''+@EndTime+' 23:59:59'''

	if(@keyWords <> '')
	begin
		set @condition +=' and Name like ''%'+@keyWords+'%'''
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderBy,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

