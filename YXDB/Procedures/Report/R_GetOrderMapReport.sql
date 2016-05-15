Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetOrderMapReport')
BEGIN
	DROP  Procedure  R_GetOrderMapReport
END
GO

/***********************************************************
过程名称： R_GetOrderMapReport
功能描述： 获取订单分布统计
参数说明：	 
编写日期： 2015/12/4
程序作者： MU
调试记录： exec R_GetOrderMapReport 1,'2014-1-1','2016-1-1','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetOrderMapReport]
	@Type int=-1,--订单类型
	@Status int=-1,--订单状态
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
	set @SqlText ='select ct.Province as name, COUNT(ct.Province) as value,SUM(od.TotalMoney) as total_money'
	set @SqlText +=' from Orders as od join City as ct  on od.CityCode = ct.CityCode'
	set @SqlText +=' where od.Status =2 and od.CityCode <>'''' and od.ClientID ='''+@ClientID+''''

	if(@UserID<>'')
	begin
		set @SqlText +=' and od.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and od.OwnerID in (select UserID from #UserID) '
	end
	else
	begin
		set @SqlText +=' and od.AgentID = '''+@AgentID+''''
	end

	if(@BeginTime<>'')
	begin
		set @SqlText +=' and od.CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and od.CreateTime <=  '''+@EndTime+' 23:59:59'''
	end
	set @SqlText +=' group by ct.Province'
end
else if(@Type=2)
begin
	set @SqlText ='select ot.TypeName as name, COUNT(ot.TypeID) as value,SUM(od.TotalMoney) as total_money'
	set @SqlText +=' from Orders as od  join OrderType as ot on od.TypeID = ot.TypeID '
	set @SqlText +=' where od.Status =2 and od.TypeID <>'''' and od.ClientID = '''+@ClientID+''''

	if(@UserID<>'')
	begin
		set @SqlText +=' and od.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and od.OwnerID in (select UserID from #UserID) '
	end
	else
	begin
		set @SqlText +=' and od.AgentID = '''+@AgentID+''''
	end

	if(@BeginTime<>'')
	begin
		set @SqlText +=' and od.CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and od.CreateTime <=  '''+@EndTime+' 23:59:59'''
	end

	set @SqlText +=' group by ot.TypeID,ot.TypeName'
end

exec(@SqlText)

GO


