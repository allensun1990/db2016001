Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientsAgentAction')
BEGIN
	DROP  Procedure  R_GetClientsAgentAction
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_GetClientsAgentAction
功能描述： 获取客户注册数量
参数说明：	 
编写日期： 2016/04/22
程序作者： Michaux
调试记录： exec R_GetClientsAgentAction 1,'2014-1-1','2017-1-1',''
************************************************************/
 Create Proc R_GetClientsAgentAction
 @DateType int=1,
 @BeginTime varchar(50)='',
 @EndTime varchar(50)='',
 @Clientid varchar(50)=''
 as
 begin
	declare @SqlText nvarchar(4000)
	declare @ObjTypes varchar(50)
	declare @SqlWhere nvarchar(4000)

	set @SqlText='select SUM(a.CustomerCount) as CustomerCount,
					SUM(a.OrdersCount) as OrdersCount,
					--SUM( a.ActivityCount) as ActivityCount, 
					SUM( a.ProductCount) as ProductCount, 
					SUM( a.UsersCount) as UsersCount, 
					--SUM( a.AgentCount) as AgentCount,
					--SUM( a.OpportunityCount) as OpportunityCount, 
					SUM( a.PurchaseCount) as PurchaseCount, 
					SUM( a.WarehousingCount) as WarehousingCount,
					SUM( a.TaskCount) as TaskCount ,  
					SUM( a.DownOrderCount) as DownOrderCount ,
					SUM( a.ProductOrderCount) as ProductOrderCount'
	set @SqlWhere=' where ReportDate between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''') '
	if(len(@Clientid)>0)
	begin
		set @SqlWhere+=' and ClientID='''+@Clientid+''' '
	end

	if(@DateType=1)
		begin
			set @SqlText+='  ,convert(varchar(8),ReportDate,112) as ReportDate from M_Report_AgentAction_Day a '
			set @SqlText+=@SqlWhere;
			set @SqlText+=' group by convert(varchar(8),ReportDate,112); '
		end
		else if(@DateType=2)
		begin
			set @SqlText+=' ,datename(year,ReportDate)+datename(week,ReportDate) as ReportDate from M_Report_AgentAction_Day a '
			set @SqlText+=@SqlWhere;
			set @SqlText+=' group by datename(year,ReportDate)+datename(week,ReportDate); '
		end
		else if(@DateType=3)
		begin
			set @SqlText+=' ,convert(varchar(6),ReportDate,112) as ReportDate from M_Report_AgentAction_Day a  '
			set @SqlText+=@SqlWhere;
			set @SqlText+=' group by convert(varchar(6),ReportDate,112); '
		end
		exec(@SqlText)
end