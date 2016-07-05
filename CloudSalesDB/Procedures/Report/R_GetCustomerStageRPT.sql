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
调试记录： exec R_GetCustomerStageRPT 'a323cd22-e07a-4d07-8ff9-178ffc04e6b6','','',1
************************************************************/

create proc [dbo].[R_GetCustomerStageRPT]
@ClientID varchar(50)='',
@BeginTime varchar(50)='',
@EndTime varchar(50)='',
@Type int=0,
@OwnerID varchar(50)=''
as

if(@BeginTime='')
begin
	set @BeginTime='1900-1-1'
end

if(@EndTime<>'')
begin
	set @EndTime= @EndTime+' 23:59:59'
end
else
begin
	set @EndTime=getdate() 
end

if(@Type=1)
begin
	if(@OwnerID<>'')
	begin
		select COUNT(StageStatus) as Value,1 as StageStatus  from Customer where ClientID=@ClientID and OwnerID=@OwnerID
		union  
		select COUNT(StageStatus) as Value,2 as StageStatus  from Customer where OpportunityTime>@BeginTime and OpportunityTime<@EndTime  and ClientID=@ClientID and OwnerID=@OwnerID
		union
		select COUNT(StageStatus) as Value,3 as StageStatus  from Customer where OrderTime>@BeginTime and OrderTime<@EndTime  and ClientID=@ClientID and OwnerID=@OwnerID

		select COUNT(0) value ,1 as StageStatus,SourceID,'' SourceName from  Customer 
		where Status<>9  and ClientID=@ClientID and OwnerID=@OwnerID
		group by SourceID
		union
			select COUNT(1) value ,2 as StageStatus,b.StageID as SourceID,b.Status  as SourceName from OpportunityStage c   
			left join Opportunity  b on b.StageID=c.StageID    
			left join Customer a on a.CustomerID=b.CustomerID
			where a.Status<>9  and b.Status<>9 and c.Status<>9 and a.OpportunityTime>@BeginTime 
			and a.OpportunityTime<@EndTime  and a.ClientID=@ClientID and a.OwnerID=@OwnerID
			group by b.StageID ,b.Status 
		union
			select COUNT(1) value ,3 as StageStatus ,'' SourceID,'' as SourceName from  Customer a 
			join Orders b on a.CustomerID=b.CustomerID  
			where a.Status<>9 and b.Status=2 and a.OrderTIme>@BeginTime 
			and a.OrderTime<@EndTime  and a.ClientID=@ClientID and a.OwnerID=@OwnerID
	end
	else
	begin
		select COUNT(StageStatus) as Value,1 as StageStatus  from Customer where ClientID=@ClientID
		union  
		select COUNT(StageStatus) as Value,2 as StageStatus  from Customer where OpportunityTime>@BeginTime and OpportunityTime<@EndTime  and ClientID=@ClientID
		union
		select COUNT(StageStatus) as Value,3 as StageStatus  from Customer where OrderTIme>@BeginTime and OrderTime<@EndTime  and ClientID=@ClientID

		select COUNT(0) value ,1 as StageStatus,SourceID,'' SourceName from  Customer 
		where Status<>9  and ClientID=@ClientID
		group by SourceID
		union
		select COUNT(1) value ,2 as StageStatus,b.StageID as SourceID,b.Status  as SourceName from OpportunityStage c   
		left join Opportunity  b on b.StageID=c.StageID    
		left join Customer a on a.CustomerID=b.CustomerID
		where a.Status<>9  and b.Status<>9 and c.Status<>9 and a.OpportunityTime>@BeginTime 
		and a.OpportunityTime<@EndTime  and a.ClientID=@ClientID 
		group by b.StageID ,b.Status 
		union
		select COUNT(1) value ,3 as StageStatus ,'' SourceID,'' as SourceName from  Customer a 
		join Orders  b on a.CustomerID=b.CustomerID   
		where a.Status<>9  and b.Status=2 and a.OrderTIme>@BeginTime 
		and a.OrderTime<@EndTime  and a.ClientID=@ClientID
	end
end
else
begin
	if(@OwnerID<>'')
		begin
		select COUNT(StageStatus) as Value,1 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime   and ClientID=@ClientID and OwnerID=@OwnerID
		union  
		select COUNT(StageStatus) as Value,2 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime and OpportunityTime>@BeginTime and OpportunityTime<@EndTime  and ClientID=@ClientID and OwnerID=@OwnerID
		union
		select COUNT(StageStatus) as Value,3 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime and OrderTime>@BeginTime and OrderTime<@EndTime  and ClientID=@ClientID and OwnerID=@OwnerID

		select COUNT(1) value ,1 as StageStatus,SourceID,'' SourceName from  Customer
		where Status<>9  and  CreateTime>@BeginTime and CreateTime<@EndTime 
		and ClientID=@ClientID and OwnerID=@OwnerID
		group by SourceID
		union
		select COUNT(1) value ,2 as StageStatus,b.StageID as SourceID,b.Status  as SourceName from  OpportunityStage c
		left join Opportunity  b on  b.StageID=c.StageID
		left join  Customer a  on  a.CustomerID=b.CustomerID  
		where a.Status<>9  and b.Status<>9 and c.Status<>9
			and a.CreateTime>@BeginTime and a.CreateTime<@EndTime 
			and a.OpportunityTime>@BeginTime and a.OpportunityTime<@EndTime  
			and a.ClientID=@ClientID and a.OwnerID=@OwnerID 
		group by b.StageID ,b.Status 
		union
		select COUNT(1) value ,3 as StageStatus ,'' SourceID,'' as SourceName from  Customer a 
		join Orders  b on a.CustomerID=b.CustomerID   and a.OrderID=b.OrderID
		where a.Status<>9  and b.Status=2
		and a.CreateTime>@BeginTime and a.CreateTime<@EndTime  
		and a.OrderTIme>@BeginTime and a.OrderTime<@EndTime  
		and a.ClientID=@ClientID and a.OwnerID=@OwnerID 
	end
	else
	begin	 
		select COUNT(StageStatus) as Value,1 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime   and ClientID=@ClientID
		union  
		select COUNT(StageStatus) as Value,2 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime and OpportunityTime>@BeginTime and OpportunityTime<@EndTime  and ClientID=@ClientID
		union
		select COUNT(StageStatus) as Value,3 as StageStatus  from Customer where CreateTime>@BeginTime and CreateTime<@EndTime and OrderTime>@BeginTime and OrderTime<@EndTime  and ClientID=@ClientID

		select COUNT(1) value ,1 as StageStatus,SourceID,'' SourceName from  Customer
		where Status<>9  and  CreateTime>@BeginTime and CreateTime<@EndTime and ClientID=@ClientID
		group by SourceID
		union
		select COUNT(1) value ,2 as StageStatus,b.StageID as SourceID,b.Status as SourceName from  OpportunityStage c  
		left join Opportunity  b on  b.StageID=c.StageID
		left join Customer a on  a.CustomerID=b.CustomerID  
		where a.Status<>9  and b.Status<>9 and c.Status<>9 and a.CreateTime>=@BeginTime and a.CreateTime<@EndTime 
		and a.OpportunityTime>@BeginTime and a.OpportunityTime<@EndTime  and a.ClientID=@ClientID
		group by b.StageID ,b.Status
		union
		select COUNT(1) value ,3 as StageStatus ,'' SourceID,'' as SourceName from  Customer a 
		join Orders  b on a.CustomerID=b.CustomerID    
		where a.Status<>9  and b.Status=2 
		and a.CreateTime>@BeginTime and a.CreateTime<@EndTime  
		and a.OrderTIme>@BeginTime and a.OrderTime<@EndTime  and a.ClientID=@ClientID
	end
end



