/*
修改存储过程
Rpt_AgentAction_Day
R_GetClientsActiveReprot
M_Get_Report_AgentAction_Day
M_Get_Report_AgentActionDayPageList
*/

alter table M_Report_AgentAction_Day add TaskCount int default(0)
GO
alter table M_Report_AgentAction_Day add DownOrderCount int default(0)
GO
alter table M_Report_AgentAction_Day add ProductOrderCount int default(0)
GO
alter table M_Report_AgentAction_Day add UserNum int default(0)
GO
alter table M_Report_AgentAction_Day add Vitality decimal(18,4) default(0.0000)
GO
update M_Report_AgentAction_Day set TaskCount=0,DownOrderCount=0,ProductOrderCount=0,UserNum=1


/*修复数据*/
delete from Report_AgentAction_Day   where  ObjectType in(10,11,12)
	
select ObjectType,ActionType,CONVERT(nvarchar(20),CreateTime,112) ReportDate, COUNT(AutoID) ReportValue,AgentID,ClientID into #temp from Log_Action
where  ObjectType  in(10,11,12) group by ObjectType,ActionType,AgentID,ClientID,CONVERT(nvarchar(20),CreateTime,112)

insert into Report_AgentAction_Day(ObjectType,ActionType,ReportDate,ReportValue,AgentID,ClientID) select ObjectType,ActionType, ReportDate, str(ReportValue),AgentID,ClientID from #temp

update d set TaskCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=10
update d set DownOrderCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=11
update d set ProductOrderCount=t.ReportValue from M_Report_AgentAction_Day d join #temp t on d.ReportDate=t.ReportDate and d.AgentID=t.AgentID where t.ObjectType=12
drop table #temp

update M_Report_AgentAction_Day set UserNum=UserCount,Vitality=
cast( 
	round(
		(CustomerCount+OrdersCOunt+ ActivityCount+ProductCount+UsersCount+AgentCount+OpportunityCount+PurchaseCount+WarehousingCount+TaskCount+DownOrderCount+ProductCount+ProductOrderCount)
		/ cast(UserNum as decimal(18,4)
	 ),4) as  decimal(18,4)
 )  
 from 
 (
	select isnull(Count(ClientID),0) as UserCount ,Users.ClientID from Users where Status=1  group by Users.ClientID
) a 
join  M_Report_AgentAction_Day   on a.ClientID=M_Report_AgentAction_Day.ClientID
 