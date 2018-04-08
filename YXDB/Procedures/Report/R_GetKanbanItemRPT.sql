
Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetKanbanItemRPT')
BEGIN
	DROP  Procedure  R_GetKanbanItemRPT
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_GetKanbanItemRPT
功能描述： 获取客户注册数量
参数说明：	 
编写日期： 2018/03/04
程序作者： Allen
调试记录： exec R_GetKanbanItemRPT 1,'moneyItem','2017-1-1','2019-1-1','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
Create PROCEDURE R_GetKanbanItemRPT
	@DateType int=1,
	@ItemType nvarchar(64),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@ClientID nvarchar(64)
as
begin
	if(@ItemType='customerItem') --客户统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Customer 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime
			group by  convert(varchar(8),CreateTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from Customer 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Customer 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
	else if(@ItemType='needItem') --需求单统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by  convert(varchar(8),CreateTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  and Status<>9
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
	else if(@ItemType='dyItem') --打样单统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=1 and OrderStatus in (1,2)
			group by  convert(varchar(8),OrderTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,OrderTime)+datename(week,OrderTime) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=1 and OrderStatus in (1,2)
			group by   datename(year,OrderTime)+datename(week,OrderTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			 where ClientID=@ClientID and OrderTime between @BeginTime and @EndTime  and Status<>9 and OrderType=1 and OrderStatus in (1,2)
			 group by   convert(varchar(6),OrderTime,112)	
		end
	end
	else if(@ItemType='dhItem') --大货单统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=2 and OrderStatus in (1,2)
			group by  convert(varchar(8),OrderTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,OrderTime)+datename(week,OrderTime) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=2 and OrderStatus in (1,2)
			group by   datename(year,OrderTime)+datename(week,OrderTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			 where ClientID=@ClientID and OrderTime between @BeginTime and @EndTime  and Status<>9 and OrderType=2 and OrderStatus in (1,2)
			 group by   convert(varchar(6),OrderTime,112)	
		end
	end
	else if(@ItemType='taskItem') --任务统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from OrderTask 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by  convert(varchar(8),CreateTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from OrderTask 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from OrderTask 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  and Status<>9
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
	else if(@ItemType='moneyItem') --收款统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),PayTime,112) as CreateTime,isnull(sum(PayMoney),0) as TotalNum from BillingPay 
			where ClientID=@ClientID and  PayTime between @BeginTime and @EndTime and Status<>9 and [Type]=2 
			group by  convert(varchar(8),PayTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,PayTime)+datename(week,PayTime) as CreateTime,isnull(sum(PayMoney),0) as TotalNum from BillingPay 
			where ClientID=@ClientID and  PayTime between @BeginTime and @EndTime and Status<>9 and [Type]=2 
			group by   datename(year,PayTime)+datename(week,PayTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),PayTime,112) as CreateTime,isnull(sum(PayMoney),0) as TotalNum from BillingPay 
			 where ClientID=@ClientID and PayTime between @BeginTime and @EndTime  and Status<>9 and [Type]=2 
			 group by   convert(varchar(6),PayTime,112)	
		end
	end
	else if(@ItemType='sendItem') --发货统计
	begin
		--按天统计
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,sum(Quantity)as TotalNum from GoodsDoc 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9 and DocType=2 
			group by  convert(varchar(8),CreateTime,112)		
		end
		--按周统计
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,sum(Quantity)as TotalNum from GoodsDoc 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9 and DocType=2 
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--按月统计
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,sum(Quantity)as TotalNum from GoodsDoc 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  and Status<>9 and DocType=2 
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
end
GO