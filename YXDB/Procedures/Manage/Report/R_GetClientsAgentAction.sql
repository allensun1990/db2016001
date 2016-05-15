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
	declare @i int
	set @SqlText=''
	set @ObjTypes='1,2,4,5,8,'
	set @i=charindex(',',@ObjTypes)
	while @i>0
	begin
		set @SqlWhere= ' where objectType='+SUBSTRING(@ObjTypes,1,@i-1)+' and ReportDate between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''') '
		if(len(@Clientid)>0)
		begin
			set @SqlWhere+=' and ClientID='''+@Clientid+''' '
		end
		if(@DateType=1)
		begin
			set @SqlText+=' select convert(varchar(8),ReportDate,112) as ReportDate,Sum(cast(ReportValue as decimal)) as ReportValue from Report_AgentAction_Day  '
			set @SqlText+=@SqlWhere;
			set @SqlText+=' group by convert(varchar(8),ReportDate,112); '
		end
		else if(@DateType=2)
		begin
			set @SqlText+=' select datename(year,ReportDate)+datename(week,ReportDate) as ReportDate,Sum(cast(ReportValue as decimal)) as ReportValue from Report_AgentAction_Day  '
			set @SqlText+=@SqlWhere;
			set @SqlText+=' group by datename(year,ReportDate)+datename(week,ReportDate); '
		end
		else if(@DateType=3)
		begin
			set @SqlText+=' select convert(varchar(6),ReportDate,112) as ReportDate,Sum(cast(ReportValue as decimal)) as ReportValue from Report_AgentAction_Day  '
			set @SqlText+=@SqlWhere;
			set @SqlText+=' group by convert(varchar(6),ReportDate,112); '
		end
		set @ObjTypes=SUBSTRING(@ObjTypes,@i+1,LEN(@ObjTypes))
		set @i=charindex(',',@ObjTypes,0)
	end
	if(@SqlText<>'')
	begin
		exec(@SqlText)
	end

end