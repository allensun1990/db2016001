Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Rpt_AgentAction_Day')
BEGIN
	DROP  Procedure  Rpt_AgentAction_Day
END

GO
/***********************************************************
过程名称： Rpt_AgentAction_Day
功能描述： 按日统计行为
参数说明：	 
编写日期： 2015/12/21
程序作者： Allen
调试记录： exec Rpt_AgentAction_Day 
************************************************************/
CREATE PROCEDURE [dbo].[Rpt_AgentAction_Day]
AS

declare @BeginTime nvarchar(50)=CONVERT(nvarchar(20),dateadd(day,-1, GETDATE()),23)+' 00:00:00',
		@EndTime nvarchar(50)= CONVERT(nvarchar(20),dateadd(day,-1, GETDATE()),23)+' 23:59:59',
		@ReportDate nvarchar(20)=CONVERT(nvarchar(20),dateadd(day,-1, GETDATE()),112)


select ObjectType,ActionType,@ReportDate ReportDate, COUNT(AutoID) ReportValue,AgentID,ClientID into #temp from Log_Action
where  CreateTime between @BeginTime and @EndTime
group by ObjectType,ActionType,AgentID,ClientID,CONVERT(nvarchar(20),CreateTime,112) 

--行为日志
insert into Report_AgentAction_Day(ObjectType,ActionType,ReportDate,ReportValue,AgentID,ClientID)
select ObjectType,ActionType, ReportDate, str(ReportValue),AgentID,ClientID from #temp

--日志处理（新）
insert into M_Report_AgentAction_Day(AgentID,ClientID,ReportDate)
select AgentID,ClientID,@ReportDate from Agents

update d set CustomerCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=1
update d set OrdersCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=2
update d set ActivityCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=3
update d set ProductCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=4
update d set UsersCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=5
update d set AgentCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=6
update d set OpportunityCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=7
update d set PurchaseCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=8
update d set WarehousingCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=9
 
--登录日志
insert into Report_AgentLogin_Day(AgentID,ClientID,ReportDate,ReportUserCount,ReportTimes)
select AgentID,ClientID,ReportDate,COUNT(UserID),SUM(Times) from
(select UserID,AgentID,ClientID,@ReportDate ReportDate,COUNT(0) Times from Log_Login 
where Status=1 and SystemType=2 and CreateTime between @BeginTime and @EndTime group by UserID,AgentID,ClientID,CONVERT(nvarchar(20),CreateTime,112)) r
group by AgentID,ClientID,ReportDate
