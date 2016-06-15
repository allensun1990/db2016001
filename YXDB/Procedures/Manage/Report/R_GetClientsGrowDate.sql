
Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientsGrowDate')
BEGIN
	DROP  Procedure  R_GetClientsGrowDate
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
�������ƣ� R_GetClientsGrowDate
���������� ��ȡ�ͻ�ע������
����˵����	 
��д���ڣ� 2016/04/21
�������ߣ� Michaux
���Լ�¼�� exec R_GetClientsGrowDate 1,'2014-1-1','2017-1-1'
************************************************************/
Create PROCEDURE R_GetClientsGrowDate
	@DateType int=1,
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)=''
as
begin
	declare @SqlText nvarchar(4000)
	set @SqlText=''
	--����ͳ��
	if(@DateType=1)
	begin	
		set @SqlText+='select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Clients '
		set @SqlText+=' where CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')  group by  convert(varchar(8),CreateTime,112)'		
		exec(@SqlText);
	end
	--����ͳ��
	else if(@DateType=2)
	begin
		set @SqlText+='select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from Clients '
		set @SqlText+=' where CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')  group by   datename(year,CreateTime)+datename(week,CreateTime)'		
		exec(@SqlText);		
	end
	--����ͳ��
	else if(@DateType=3)
	begin	
		set @SqlText+='select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Clients '
		set @SqlText+=' where CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')  group by   convert(varchar(6),CreateTime,112)'		
		exec(@SqlText);
	end

end
GO