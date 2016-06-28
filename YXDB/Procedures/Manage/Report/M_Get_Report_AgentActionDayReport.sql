USE [IntFactory]
GO
/****** Object:  StoredProcedure [dbo].[M_Get_Report_AgentActionDayReport]    Script Date: 05/23/2016 13:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_Get_Report_AgentActionDayReport
功能描述： 查询客户行为报表	 
编写日期： 2015/12/4
程序作者： MU
修改信息:  Michaux 2016-05-23
修改说明:  添加根据工厂ID查询
调试记录： exec [M_Get_Report_AgentActionDayReport] 1,'2016-04-04','2016-04-07',''
************************************************************/
Create PROCEDURE [dbo].[M_Get_Report_AgentActionDayReport]
@DateType int=1,
@BeginDate nvarchar(100)='',
@EndDate nvarchar(100)='',
@ClientID nvarchar(100)=''
AS
begin
	declare @sqlStr nvarchar(4000),
	@tableName nvarchar(400),
	@columns nvarchar(1000),
	@condition nvarchar(400),
	@groupColumn nvarchar(100),
	@orderColumn nvarchar(100)

	set @sqlStr=''
	set @tableName='M_Report_AgentAction_Day a '
	set @columns=' SUM(a.CustomerCount) as CustomerCount,
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
	  SUM( a.ProductOrderCount) as ProductOrderCount,
	  SUM(a.Vitality)/count(a.ClientID) as Vitality '
	  set @condition=' where 1=1'

	if(@BeginDate<>'')
		set @condition+=' and a.ReportDate>='''+@BeginDate+''''
	if(@EndDate<>'')
		set @condition+=' and a.ReportDate<='''+CONVERT(varchar(100), dateadd(day, 1, @EndDate), 23)+''''
	if(@DateType=1)
	begin	
		set @columns=@columns+',convert(varchar(8),a.ReportDate,112) ReportDate '
		set @groupColumn=' group by convert(varchar(8),a.ReportDate,112) '
		set @orderColumn='order by convert(varchar(8),a.ReportDate,112) asc'
	end
	else if(@DateType=2)
	begin
		set @columns=@columns+',datename(year,a.ReportDate)+datename(week,a.ReportDate) as ReportDate  '
		set @groupColumn=' group by   datename(year,a.ReportDate)+datename(week,a.ReportDate)'	
			set @orderColumn='order by datename(year,a.ReportDate)+datename(week,a.ReportDate) asc'	 
	end
	else if(@DateType=3)
	begin	
		set @columns=@columns+', convert(varchar(6),a.ReportDate,112) as ReportDate  '
		set @groupColumn=' group by   convert(varchar(6),a.ReportDate,112)'		
		set @orderColumn='order by convert(varchar(6),a.ReportDate,112) asc'
	end  
	set @sqlStr='select '+@columns+' from '+@tableName+@condition+@groupColumn+@orderColumn

	--print @sqlStr
	exec(@sqlStr)

end
