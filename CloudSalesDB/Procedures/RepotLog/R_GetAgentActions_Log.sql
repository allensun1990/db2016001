Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetAgentActions_Log')
BEGIN
	DROP  Procedure  R_GetAgentActions_Log
END

GO
/***********************************************************
过程名称： R_GetAgentActions_Log
功能描述： 按日统计行为
参数说明：	 
编写日期： 2015/12/22
程序作者： Allen
调试记录： exec R_GetAgentActions_Log '2015-12-22 00:00:00','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetAgentActions_Log]
@DateTime datetime,
@AgentID nvarchar(64)
AS

declare @Days int=0,@Week int=0,@Month int=0

select @Month=isnull(sum(ReportUserCount),0) from Report_AgentLogin_Day 
where AgentID=@AgentID and ReportDate between DATEADD(MONTH,-1,@DateTime)  and @DateTime

select @Week=isnull(sum(ReportUserCount),0) from Report_AgentLogin_Day 
where AgentID=@AgentID and ReportDate between DATEADD(week,-1,@DateTime)  and @DateTime

select @Days=isnull(sum(ReportUserCount),0) from Report_AgentLogin_Day 
where AgentID=@AgentID and ReportDate between DATEADD(DAY,-1,@DateTime)  and @DateTime

create table #Result(ObjectType int ,DayValue decimal(18,4),WeekValue decimal(18,4),MonthValue decimal(18,4))

--上月
insert into #Result(ObjectType,DayValue,WeekValue,MonthValue)
select ObjectType,0,0,SUM(convert(decimal(18,4),ReportValue)) 
from Report_AgentAction_Day 
where AgentID=@AgentID and ReportDate between DATEADD(MONTH,-1,@DateTime)  and @DateTime
group by ObjectType

--上周
select ObjectType,SUM(convert(decimal(18,4),ReportValue)) Value into #Week
from Report_AgentAction_Day 
where AgentID=@AgentID and ReportDate between DATEADD(week,-1,@DateTime)  and @DateTime
group by ObjectType

update r set WeekValue=w.Value from #Result r join #Week w on r.ObjectType=w.ObjectType  

--昨天
select ObjectType,SUM(convert(decimal(18,4),ReportValue)) Value into #Day
from Report_AgentAction_Day 
where AgentID=@AgentID and ReportDate between DATEADD(day,-1,@DateTime)  and @DateTime
group by ObjectType

update r set WeekValue=w.Value from #Result r join #Day w on r.ObjectType=w.ObjectType

--登录
insert into #Result values(0,@Days,@Week,@Month)

select * from #Result
