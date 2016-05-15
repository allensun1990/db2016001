Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_Get_Report_AgentAction_Day')
BEGIN
	DROP  Procedure  M_Get_Report_AgentAction_Day
END

GO
/***********************************************************
过程名称： M_Get_Report_AgentAction_Day
功能描述： 查询客户订单列表
参数说明：	 
编写日期： 2015/12/4
程序作者： MU
调试记录： exec M_Get_Report_AgentAction_Day 
************************************************************/
CREATE PROCEDURE [dbo].M_Get_Report_AgentAction_Day
@Keyword nvarchar(100)='',
@BeginDate nvarchar(100)='',
@EndDate nvarchar(100)=''
AS
	declare @sqlStr nvarchar(4000),
	@tableName nvarchar(400),
	@columns nvarchar(400),
	@condition nvarchar(400),
	@groupColumn nvarchar(100)
	
	set @sqlStr=''
	set @tableName='M_Report_AgentAction_Day'
	set @columns='AgentID,SUM(CustomerCount) as Customer,
	  SUM(OrdersCount) as Orders,
	  SUM( ActivityCount) as Activity,
	  SUM( ProductCount) as Product,
	  SUM( UsersCount) as Users,
	  SUM( AgentCount) as Agent,
	  SUM( OpportunityCount) as Opportunity,
	  SUM( PurchaseCount) as Purchase,
	  SUM( WarehousingCount) as Warehousing'
	  set @condition=' where ActionType=1 '

	if(@BeginDate<>'')
		set @condition+=' and ReportDate>='''+@BeginDate+''''
	if(@EndDate<>'')
		set @condition+=' and ReportDate<='''+dateadd(day, 1, @EndDate)+''''

	set @groupColumn=' group by AgentID'

	set @sqlStr='select '+@columns+' from '+@tableName+@condition+@groupColumn

	exec(@sqlStr)

  






