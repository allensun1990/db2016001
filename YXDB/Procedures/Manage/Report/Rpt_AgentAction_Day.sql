USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Rpt_AgentAction_Day')
BEGIN
	DROP  Procedure  Rpt_AgentAction_Day
END

GO
/****** Object:  StoredProcedure [dbo].[Rpt_AgentAction_Day]    Script Date: 05/21/2016 12:15:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***********************************************************
过程名称： Rpt_AgentAction_Day
功能描述： 按日统计行为
参数说明：	 
编写日期： 2015/12/21
程序作者： Allen
调试记录： exec Rpt_AgentAction_Day 
修改信息: 2015/05/21 Michaux 添加任务数 拉单次数 生产订单数
************************************************************/
CREATE PROCEDURE [dbo].[Rpt_AgentAction_Day]
AS

declare @BeginTime nvarchar(50)=CONVERT(nvarchar(20),dateadd(day,-1, GETDATE()),23)+' 00:00:00',
		@EndTime nvarchar(50)= CONVERT(nvarchar(20),dateadd(day,-1, GETDATE()),23)+' 23:59:59',
		@ReportDate nvarchar(20)=CONVERT(nvarchar(20),dateadd(day,-1, GETDATE()),112)


select ObjectType,ActionType,@ReportDate ReportDate, COUNT(AutoID) ReportValue,ClientID into #temp from Log_Action
where  CreateTime between @BeginTime and @EndTime
group by ObjectType,ActionType,ClientID,CONVERT(nvarchar(20),CreateTime,112) 

--行为日志
insert into Report_AgentAction_Day(ObjectType,ActionType,ReportDate,ReportValue,ClientID)
select ObjectType,ActionType, ReportDate, str(ReportValue),ClientID from #temp

--日志处理（新）
insert into M_Report_AgentAction_Day(ClientID,ReportDate)
select ClientID,@ReportDate from Agents

update d set CustomerCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=1
update d set OrdersCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=2
update d set ActivityCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=3
update d set ProductCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=4
update d set UsersCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=5
update d set AgentCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=6
update d set OpportunityCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=7
update d set PurchaseCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=8
update d set WarehousingCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=9
update d set TaskCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=10
update d set DownOrderCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=11
update d set ProductOrderCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=12
update d set UserNum=UserCount from ( select isnull(Count(ClientID),0) as UserCount ,Users.ClientID from Users where Status=1  group by Users.ClientID) a join  M_Report_AgentAction_Day d  on a.ClientID=d.ClientID where  d.ReportDate=@ReportDate
update M_Report_AgentAction_Day set Vitality=cast( round((CustomerCount+OrdersCOunt+ ActivityCount+ProductCount+UsersCount+AgentCount+OpportunityCount+PurchaseCount+WarehousingCount+TaskCount+DownOrderCount+ProductCount+ProductOrderCount)
 / cast(UserNum as decimal(18,4)  ),4) as  decimal(18,4)) where ReportDate=@ReportDate


--登录日志
insert into Report_AgentLogin_Day(ClientID,ReportDate,ReportUserCount,ReportTimes)
select ClientID,ReportDate,COUNT(UserID),SUM(Times) from
(select UserID,ClientID,@ReportDate ReportDate,COUNT(0) Times from Log_Login 
where Status=1 and SystemType=2 and CreateTime between @BeginTime and @EndTime group by UserID,ClientID,CONVERT(nvarchar(20),CreateTime,112)) r
group by ClientID,ReportDate
