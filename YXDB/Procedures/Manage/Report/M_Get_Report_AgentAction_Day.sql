
USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_Get_Report_AgentAction_Day')
BEGIN
	DROP  Procedure  M_Get_Report_AgentAction_Day
END

GO
/****** Object:  StoredProcedure [dbo].[M_Get_Report_AgentAction_Day]    Script Date: 05/10/2016 15:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_Get_Report_AgentAction_Day
功能描述： 查询客户订单列表	 
编写日期： 2015/12/4
程序作者： MU
修改信息:  Michaux 2016-05-10 
修改说明:  添加根据工厂ID查询
调试记录： exec M_Get_Report_AgentAction_Day '','2016-04-04','2016-04-07',''
************************************************************/
Create PROCEDURE [M_Get_Report_AgentAction_Day]
@Keyword nvarchar(100)='',
@BeginDate nvarchar(100)='',
@EndDate nvarchar(100)='',
@ClientID nvarchar(100)=''
AS
	declare @sqlStr nvarchar(4000),
	@tableName nvarchar(400),
	@columns nvarchar(1000),
	@condition nvarchar(400),
	@groupColumn nvarchar(100),
	@orderColumn nvarchar(100)
	
	set @sqlStr=''
	set @tableName='M_Report_AgentAction_Day as a left join Clients as c on a.ClientID=c.ClientID'
	set @columns='a.ClientID,c.ClientCode,c.CompanyName,c.createtime,SUM(a.CustomerCount) as CustomerCount,
	  SUM(a.OrdersCount) as OrdersCount,
	  SUM( a.ActivityCount) as ActivityCount,
	  SUM( a.ProductCount) as ProductCount,
	  SUM( a.UsersCount) as UsersCount,
	  SUM( a.AgentCount) as AgentCount,
	  SUM( a.OpportunityCount) as OpportunityCount,
	  SUM( a.PurchaseCount) as PurchaseCount,
	  SUM( a.WarehousingCount) as WarehousingCount ,
	  SUM( a.TaskCount) as TaskCount ,
	  SUM( a.DownOrderCount) as DownOrderCount ,
	  SUM( a.ProductOrderCount) as ProductOrderCount'
	  if(len(@EndDate)>0)
	  begin
		set @columns=@columns+ ',SUM(a.Vitality)/DATEDIFF(day,'''+@BeginDate+''',dateadd(day, 1,'''+ @EndDate+''')) as Vitality '
	  end
	  else begin
		set @columns=@columns+ ',SUM(a.Vitality)/count(a.ClientID) as Vitality '
	  end
	  set @condition=' where c.Status=1 '

	if(@Keyword<>'')
		set @condition+=' and c.CompanyName like''%'+@Keyword+'%'''
	if(@ClientID<>'')
		set @condition+=' and a.ClientID='''+@ClientID+''''
	if(@BeginDate<>'')
		set @condition+=' and a.ReportDate>='''+@BeginDate+''''
	if(@EndDate<>'')
		set @condition+=' and a.ReportDate<='''+CONVERT(varchar(100), dateadd(day, 1, @EndDate), 23)+''''

	set @groupColumn=' group by a.ClientID,c.CompanyName,c.createtime,c.ClientCode'
	set @orderColumn=' order by c.createtime desc'

	set @sqlStr='select '+@columns+' from '+@tableName+@condition+@groupColumn+@orderColumn

	--print @sqlStr
	exec(@sqlStr)


