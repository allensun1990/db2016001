Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetCustomerStageRPT')
BEGIN
	DROP  Procedure  R_GetCustomerStageRPT
END

GO
/***********************************************************
过程名称： R_GetCustomerStageRPT
功能描述： 客户转化率
参数说明：	 
编写日期： 2016/06/13
程序作者： Michaux
调试记录： exec R_GetCustomerStageRPT '','','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/

create proc [dbo].[R_GetCustomerStageRPT]
@ClientID varchar(50)='',
@BeginTime varchar(50)='',
@EndTime varchar(50)='',
@Type int=0
as

if(@EndTime<>'')
begin
set @EndTime= @EndTime+' 23:59:59'
end

if(@Type=1)
begin
	select COUNT(StageStatus) as Value,1 as StageStatus  from Customer where ClientID=@ClientID
	union  
	select COUNT(StageStatus) as Value,2 as StageStatus  from Customer where OpportunityTime>@BeginTime and OpportunityTime<@EndTime  and ClientID=@ClientID
	union
	select COUNT(StageStatus) as Value,3 as StageStatus  from Customer where OrderTIme>@BeginTime and OrderTime<@EndTime  and ClientID=@ClientID

	select COUNT(1) value ,1 as StageStatus,b.SourceCode,b.SourceName from  Customer a  left  join CustomSource  b on a.SourceID=b.SourceID 
	where a.Status<>9  and b.Status<>9  and  a.CreateTime>@BeginTime and a.CreateTime<@EndTime and a.ClientID=@ClientID
	group by b.SourceCode,b.SourceName
	union
	select COUNT(1) value ,2 as StageStatus,b.StageID as SourceCode,c.StageName as SourceName from  Customer a 
	 left  join Opportunity  b on a.CustomerID=b.CustomerID  
	 left join OpportunityStage c on b.StageID=c.StageID
	  and b.OpportunityID=a.OpportunityID
	where a.Status<>9  and b.Status<>9 and c.Status<>9 and a.OpportunityTime>@BeginTime and a.OpportunityTime<@EndTime  and a.ClientID=@ClientID
	group by b.StageID ,c.StageName 
	union
	select COUNT(1) value ,3 as StageStatus ,'' SourceCode,'' as SourceName from  Customer a 
	 left  join Orders  b on a.CustomerID=b.CustomerID    and a.OrderID=b.OrderID
	where a.Status<>9  and b.Status<>9     and a.OrderTIme>@BeginTime and a.OrderTime<@EndTime  and a.ClientID=@ClientID
end
else
begin
	select COUNT(StageStatus) as Value,1 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime   and ClientID=@ClientID
	union  
	select COUNT(StageStatus) as Value,2 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime and OpportunityTime>@BeginTime and OpportunityTime<@EndTime  and ClientID=@ClientID
	union
	select COUNT(StageStatus) as Value,3 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime and OrderTime>@BeginTime and OrderTime<@EndTime  and ClientID=@ClientID

	select COUNT(1) value ,1 as StageStatus,b.SourceCode,b.SourceName from  Customer a  left  join CustomSource  b on a.SourceID=b.SourceID 
	where a.Status<>9  and b.Status<>9  and  a.CreateTime>@BeginTime and a.CreateTime<@EndTime and a.ClientID=@ClientID
	group by b.SourceCode,b.SourceName,StageStatus
	union
	select COUNT(1) value ,2 as StageStatus,b.StageID as SourceCode,c.StageName as SourceName from  Customer a 
	 left  join Opportunity  b on a.CustomerID=b.CustomerID  
	 left join OpportunityStage c on b.StageID=c.StageID
	  and b.OpportunityID=a.OpportunityID
	where a.Status<>9  and b.Status<>9 and c.Status<>9 and a.CreateTime>@BeginTime and a.CreateTime<@EndTime and a.OpportunityTime>@BeginTime and a.OpportunityTime<@EndTime  and a.ClientID=@ClientID
	group by b.StageID ,c.StageName 
	union
	select COUNT(1) value ,3 as StageStatus ,'' SourceCode,'' as SourceName from  Customer a 
	 left  join Orders  b on a.CustomerID=b.CustomerID   and a.OrderID=b.OrderID
	where a.Status<>9  and b.Status<>9  and a.CreateTime>@BeginTime and a.CreateTime<@EndTime  and a.OrderTIme>@BeginTime and a.OrderTime<@EndTime  and a.ClientID=@ClientID

end



