Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetOpportunityStateRPT')
BEGIN
	DROP  Procedure  R_GetOpportunityStateRPT
END

GO
/***********************************************************
过程名称： R_GetOpportunityStateRPT
功能描述： 机会各阶段数值统计
参数说明：	 
编写日期： 2016/06/28
程序作者： Michaux
调试记录： exec R_GetOpportunityStateRPT 'a323cd22-e07a-4d07-8ff9-178ffc04e6b6','','' 
************************************************************/

Create proc R_GetOpportunityStateRPT
@ClientID varchar(50)='',
@BeginTime varchar(50)='',
@EndTime varchar(50),
@Type int =0,
@OwnerID varchar(50)=''
as
begin
	if(@BeginTime='' ) 
		set @BeginTime='1990-01-01' 
	if(@EndTime=''or @Type=1) 
		set @EndTime=GETDATE()  
	else   
		set @EndTime=+' 23:59:59' 

	declare @sqlText varchar(4000)

	set @sqlText='select a.Status,a.StageID,count(1) value from  Opportunity  a 
			left join OpportunityStage b on  a.StageID=b.StageID 
		where a.Status<>9   
			and a.ClientID='''+@ClientID+'''
			and a.CreateTime >'''+@BeginTime+''' and a.CreateTime<='''+@EndTime+''''	
	if(@OwnerID<>'')
		set @sqlText+=' and a.OwnerID='''+@OwnerID+''''

	if(@Type=1)
	begin
		set @sqlText=@sqlText+'	and a.CustomerID  in (
				select  distinct CustomerID from  Customer where a.status<>9 
					and ClientID='''+@ClientID+''' and OpportunityTime >'''+ @BeginTime+''' and OpportunityTime<='''+@EndTime+'''
				) '
	end

	exec(@sqlText+' group by a.Status ,a.StageID order by a.status ') 
END