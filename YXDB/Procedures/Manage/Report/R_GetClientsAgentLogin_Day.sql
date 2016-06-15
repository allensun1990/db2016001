Use IntFactory
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
�������ƣ� R_GetClientsAgentLogin_Day
���������� ��ȡ����ע������
����˵����	 
��д���ڣ� 2016/04/21
�������ߣ� Michaux
���Լ�¼�� exec R_GetClientsAgentLogin_Day 1,'2014-1-1','2017-1-1'
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
	--����ͳ��
	if(@DateType=1)
	begin		
		--��¼����
		set @SqlText+='select Convert(varchar(8),ReportDate,112) as ReportDate,sum(ReportTimes) as Num from Report_AgentLogin_Day '
		set @SqlText+= @SqlWhere+'  group by  Convert(varchar(8),ReportDate,112); '		
		--��½����
		set @SqlText+='select Convert(varchar(8),ReportDate,112) as ReportDate ,sum(ReportUserCount) as Num from Report_AgentLogin_Day '
		set @SqlText+= @SqlWhere +' group by  Convert(varchar(8),ReportDate,112); ';		
		--��½������
		set @SqlText+='select Convert(varchar(8),ReportDate,112)  as ReportDate ,count(distinct ClientID) as Num from Report_AgentLogin_Day '
		set @SqlText+= @SqlWhere +'  group by   Convert(varchar(8),ReportDate,112) ; '		
		exec(@SqlText);
	end
	else if(@DateType=2)
	begin
		--��¼����
		set @SqlText+='select datename(year,ReportDate)+datename(week,ReportDate) as ReportDate,sum(ReportTimes) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+'  group by  datename(year,ReportDate)+datename(week,ReportDate); '
		--��½����	
		set @SqlText+='select datename(year,ReportDate)+datename(week,ReportDate) as ReportDate ,sum(ReportUserCount) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by  datename(year,ReportDate)+datename(week,ReportDate); '	
		--��½������
		set @SqlText+='select datename(year,ReportDate)+datename(week,ReportDate) AS ReportDate ,count(distinct ClientID) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by  datename(year,ReportDate)+datename(week,ReportDate); '	
		exec(@SqlText);	
	end
	else if(@DateType=3)
	begin
		--��¼����
		set @SqlText+='select Convert(varchar(6),ReportDate,112) as ReportDate,sum(ReportTimes) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+'  group by   Convert(varchar(6),ReportDate,112); '	
		--��½����
		set @SqlText+='select Convert(varchar(6),ReportDate,112) as ReportDate ,sum(ReportUserCount) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by   Convert(varchar(6),ReportDate,112); '	
		--��½������
		set @SqlText+='select Convert(varchar(6),ReportDate,112) AS ReportDate ,count(distinct ClientID) as Num from Report_AgentLogin_Day '
		set @SqlText+=@SqlWhere+' group by  Convert(varchar(6),ReportDate,112); '	
		exec(@SqlText);	
	end
end
GO