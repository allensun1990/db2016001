Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetCustomerReport')
BEGIN
	DROP  Procedure  R_GetCustomerReport
END
GO

/***********************************************************
过程名称： R_GetCustomerReport
功能描述： 获取客户地区分布统计
参数说明：	 
编写日期： 2015/12/1
程序作者： MU
调试记录： exec R_GetCustomerReport 1,'2014-1-1','2016-1-1','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetCustomerReport]
	@Type int=1,--1:按地区；2、按行业；3、按规模
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

declare @SqlText nvarchar(4000)

create table #UserID(UserID nvarchar(64))

if(@Type=1)
begin
	set @SqlText ='select ct.Province as name, COUNT(ct.Province) as value from Customer as cm'
	set @SqlText +=' join City as ct  on cm.CityCode = ct.CityCode '
	set @SqlText +='where cm.ClientID = '''+@ClientID+''' and cm.Status <> 9 and cm.CityCode != '''''

	if(@UserID<>'')
	begin
		set @SqlText +=' and cm.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and cm.OwnerID in (select UserID from #UserID) '
	end
	else
	begin
		set @SqlText +=' and cm.AgentID = '''+@AgentID+''''
	end

	if(@BeginTime<>'')
	begin
		set @SqlText +=' and cm.CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and cm.CreateTime <=  '''+@EndTime+' 23:59:59'''
	end
	set @SqlText +=' group by ct.Province'
end
else if(@Type=2)
begin
	set @SqlText =' select it.Name as name, COUNT(it.Name) as value from Customer as cm '
	set @SqlText +=' join Industry as it on cm.IndustryID = it.IndustryID '
	set @SqlText +='  where cm.Status <> 9 and cm.IndustryID != '''' and cm.ClientID = '''+@ClientID+''''

	if(@UserID<>'')
	begin
		set @SqlText +=' and cm.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and cm.OwnerID in (select UserID from #UserID) '
	end
	else
	begin
		set @SqlText +=' and cm.AgentID = '''+@AgentID+''''
	end

	if(@BeginTime<>'')
	begin
		set @SqlText +=' and cm.CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and cm.CreateTime <=  '''+@EndTime+' 23:59:59'''
	end

	set @SqlText +=' group by it.Name'
end
else if(@Type=3)
begin
	set @SqlText ='select Extent as name, COUNT(Extent) as value from Customer as cm'
	set @SqlText +=' where Status <> 9  and Extent > 0 and ClientID = '''+@ClientID+''''

	if(@UserID<>'')
	begin
		set @SqlText +=' and cm.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and cm.OwnerID in (select UserID from #UserID) '
	end
	else
	begin
		set @SqlText +=' and cm.AgentID = '''+@AgentID+''''
	end

	if(@BeginTime<>'')
	begin
		set @SqlText +=' and cm.CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and cm.CreateTime <=  '''+@EndTime+' 23:59:59'''
	end

	set @SqlText +=' group by Extent'
end

exec(@SqlText)

GO


