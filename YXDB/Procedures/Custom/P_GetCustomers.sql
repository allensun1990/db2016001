Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetCustomers')
BEGIN
	DROP  Procedure  P_GetCustomers
END

GO
/***********************************************************
过程名称： P_GetCustomers
功能描述： 获取客户列表
参数说明：	 
编写日期： 2015/11/5
程序作者： Allen
调试记录： exec P_GetCustomers 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetCustomers]
	@SearchType int,
	@Type int=-1,
	@SourceType int=-1,
	@SourceID nvarchar(64)='',
	@StageID nvarchar(64)='',
	@Status int=-1,
	@Mark int=-1,
	@SearchUserID nvarchar(64)='',
	@SearchTeamID nvarchar(64)='',
	@FirstName nvarchar(10)='',
	@Keywords nvarchar(4000),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@pageSize int,
	@pageIndex int,
	@OrderBy nvarchar(4000)='cus.CreateTime desc',
	@totalCount int output ,
	@pageCount int output,
	@UserID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@isAsc int

	select @tableName='Customer cus',
	@columns='cus.* ',
	@key='cus.AutoID',
	@isAsc=0

	set @condition='cus.ClientID='''+@ClientID+''' and cus.Status<>9 '

	create table #UserID(UserID nvarchar(64))

	if(@SearchType=1) --我的
	begin
		set @condition +=' and cus.OwnerID = '''+@UserID+''''
	end
	else if(@SearchType=2) --下属
	begin
		if(@SearchUserID<>'')
		begin
			set @condition +=' and cus.OwnerID = '''+@SearchUserID+''''
		end
		else
		begin
			with TempUser(UserID)
			as
			(
				select UserID from Users where ParentID=@UserID and Status<>9
				union all
				select u.UserID from Users u join TempUser t on u.ParentID=t.UserID and Status<>9
			)
			insert into #UserID select UserID from TempUser

			set @condition +=' and cus.OwnerID in (select UserID from #UserID) '
		end
	end
	else --全部
	begin
		if(@SearchUserID<>'')
		begin
			set @condition +=' and cus.OwnerID = '''+@SearchUserID+''''
		end
		else if(@SearchTeamID<>'')
		begin
			insert into #UserID select UserID from TeamUser where TeamID=@SearchTeamID and status=1
			set @condition +=' and cus.OwnerID in (select UserID from #UserID) '
		end
	end

	if(@Type<>-1)
	begin
		set @condition +=' and cus.Type = '+convert(nvarchar(2), @Type)
	end

	if(@SourceType<>-1)
	begin
		set @condition +=' and cus.SourceType = '+convert(nvarchar(2), @SourceType)
	end

	if(@SourceID<>'')
	begin
		set @condition +=' and cus.SourceID = '''+@SourceID+''''
	end

	if(@Status<>-1)
	begin
		set @condition +=' and cus.Status = '+convert(nvarchar(2), @Status)
	end

	if(@Mark<>-1)
	begin
		set @condition +=' and cus.Mark = '+convert(nvarchar(2), @Mark)
	end

	if(@BeginTime<>'')
		set @condition +=' and cus.CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and cus.CreateTime <=  '''+@EndTime+' 23:59:59'''

	if(@FirstName<>'')
	set @condition +=' and FirstName = '''+@FirstName+''''

	if(@keyWords <> '')
	begin
		set @condition +=' and (cus.Name like ''%'+@keyWords+'%'' or cus.MobilePhone like ''%'+@keyWords+'%'''+' or cus.FirstName = '''+@keyWords+''' )'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@OrderBy,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

