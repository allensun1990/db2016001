Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientsAgentLogin_Day')
BEGIN
	DROP  Procedure  R_GetClientsAgentLogin_Day
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_GetClientsAgentLogin_Day
功能描述： 获取客户注册数量
参数说明：	 
编写日期： 2016/07/21
程序作者： Michaux
调试记录： exec R_GetClientsAgentLogin_Day 1,'2014-1-1','2017-1-1'
************************************************************/
Create PROCEDURE R_GetClientsAgentLogin_Day
	@DateType int=1,
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)=''
as
begin
	declare @SqlText nvarchar(4000)
	declare @SqlWhere nvarchar(4000)
	set @SqlText=''
	set @SqlWhere=' where ReportDate between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''') '
	--按天统计
	if(@DateType=1)
	begin		
		--登录次数
		set @SqlText+='select Convert(varchar(8),ReportDate,112) as ReportDate,sum(ReportTimes) as Num from Report_AgentLogin_Day '
		set @SqlText+= @SqlWhere+'  group by  Convert(varchar(8),ReportDate,112); '		
		--登陆人数
		set @SqlText+='select Convert(varchar(8),ReportDate,112) as ReportDate ,sum(ReportUserCount) as Num from Report_AgentLogin_Day '
		set @SqlText+= @SqlWhere +' group by  Convert(varchar(8),ReportDate,112); ';		
		--登陆工厂数
		set @SqlText+='select Convert(varchar(8),ReportDate,112)  as ReportDate ,count(distinct ClientID) as Num from Report_AgentLogin_Day '
		set @SqlText+= @SqlWhere +'  group by   Convert(varchar(8),ReportDate,112) ; '		
		exec(@SqlText);
	end
	else if(@DateType=2)
	begin
		--登录次数
		set @SqlText+='select datename(year,ReportDate)+datename(week,ReportDate) as ReportDate,sum(ReportTimes) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+'  group by  datename(year,ReportDate)+datename(week,ReportDate); '
		--登陆人数	
		set @SqlText+='select datename(year,ReportDate)+datename(week,ReportDate) as ReportDate ,sum(ReportUserCount) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by  datename(year,ReportDate)+datename(week,ReportDate); '	
		--登陆工厂数
		set @SqlText+='select datename(year,ReportDate)+datename(week,ReportDate) AS ReportDate ,count(distinct ClientID) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by  datename(year,ReportDate)+datename(week,ReportDate); '	
		exec(@SqlText);	
	end
	else if(@DateType=3)
	begin
		--登录次数
		set @SqlText+='select Convert(varchar(6),ReportDate,112) as ReportDate,sum(ReportTimes) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+'  group by   Convert(varchar(6),ReportDate,112); '	
		--登陆人数
		set @SqlText+='select Convert(varchar(6),ReportDate,112) as ReportDate ,sum(ReportUserCount) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by   Convert(varchar(6),ReportDate,112); '	
		--登陆工厂数
		set @SqlText+='select Convert(varchar(6),ReportDate,112) AS ReportDate ,count(distinct ClientID) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by  Convert(varchar(6),ReportDate,112); '	
		exec(@SqlText);	
	end
end
GO