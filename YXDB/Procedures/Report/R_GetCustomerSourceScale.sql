Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetCustomerSourceScale')
BEGIN
	DROP  Procedure  R_GetCustomerSourceScale
END

GO
/***********************************************************
过程名称： R_GetCustomerSourceScale
功能描述： 获取客户来源统计
参数说明：	 
编写日期： 2015/11/30
程序作者： Allen
调试记录： exec R_GetCustomerSourceScale '','','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetCustomerSourceScale]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)

	create table #TempData(SourceID nvarchar(64),CustomerCount int)
	create table #UserID(UserID nvarchar(64))

	set @SqlText='insert into #TempData select SourceID,count(AutoID) CustomerCount  from Customer where ClientID='''+@ClientID+''''

	if(@UserID<>'')
	begin
		set @SqlText +=' and OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and OwnerID in (select UserID from #UserID) '
	end

	if(@BeginTime<>'')
	begin
		set @SqlText +=' and CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and CreateTime <=  '''+@EndTime+' 23:59:59'''
	end

	set @SqlText+='Group by SourceID'

	exec(@SqlText)

	select s.SourceID,s.SourceName Name,isnull(d.CustomerCount,0) Value from CustomSource s left join #TempData d on s.SourceID=d.SourceID where s.ClientID=@ClientID

 

