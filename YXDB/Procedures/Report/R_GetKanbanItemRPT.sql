
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
�������ƣ� R_GetKanbanItemRPT
���������� ��ȡ�ͻ�ע������
����˵����	 
��д���ڣ� 2018/03/04
�������ߣ� Allen
���Լ�¼�� exec R_GetKanbanItemRPT 1,'moneyItem','2017-1-1','2019-1-1','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
Create PROCEDURE R_GetKanbanItemRPT
	@DateType int=1,
	@ItemType nvarchar(64),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@ClientID nvarchar(64)
as
begin
	if(@ItemType='customerItem') --�ͻ�ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Customer 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime
			group by  convert(varchar(8),CreateTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from Customer 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Customer 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
	else if(@ItemType='needItem') --����ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by  convert(varchar(8),CreateTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  and Status<>9
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
	else if(@ItemType='dyItem') --������ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=1 and OrderStatus in (1,2)
			group by  convert(varchar(8),OrderTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,OrderTime)+datename(week,OrderTime) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=1 and OrderStatus in (1,2)
			group by   datename(year,OrderTime)+datename(week,OrderTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			 where ClientID=@ClientID and OrderTime between @BeginTime and @EndTime  and Status<>9 and OrderType=1 and OrderStatus in (1,2)
			 group by   convert(varchar(6),OrderTime,112)	
		end
	end
	else if(@ItemType='dhItem') --�����ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=2 and OrderStatus in (1,2)
			group by  convert(varchar(8),OrderTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,OrderTime)+datename(week,OrderTime) as CreateTime,COUNT(1)as TotalNum from Orders 
			where ClientID=@ClientID and  OrderTime between @BeginTime and @EndTime and Status<>9 and OrderType=2 and OrderStatus in (1,2)
			group by   datename(year,OrderTime)+datename(week,OrderTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),OrderTime,112) as CreateTime,COUNT(1)as TotalNum from Orders 
			 where ClientID=@ClientID and OrderTime between @BeginTime and @EndTime  and Status<>9 and OrderType=2 and OrderStatus in (1,2)
			 group by   convert(varchar(6),OrderTime,112)	
		end
	end
	else if(@ItemType='taskItem') --����ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from OrderTask 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by  convert(varchar(8),CreateTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from OrderTask 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from OrderTask 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  and Status<>9
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
	else if(@ItemType='moneyItem') --�տ�ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),PayTime,112) as CreateTime,isnull(sum(PayMoney),0) as TotalNum from BillingPay 
			where ClientID=@ClientID and  PayTime between @BeginTime and @EndTime and Status<>9 and [Type]=2 
			group by  convert(varchar(8),PayTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,PayTime)+datename(week,PayTime) as CreateTime,isnull(sum(PayMoney),0) as TotalNum from BillingPay 
			where ClientID=@ClientID and  PayTime between @BeginTime and @EndTime and Status<>9 and [Type]=2 
			group by   datename(year,PayTime)+datename(week,PayTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),PayTime,112) as CreateTime,isnull(sum(PayMoney),0) as TotalNum from BillingPay 
			 where ClientID=@ClientID and PayTime between @BeginTime and @EndTime  and Status<>9 and [Type]=2 
			 group by   convert(varchar(6),PayTime,112)	
		end
	end
	else if(@ItemType='sendItem') --����ͳ��
	begin
		--����ͳ��
		if(@DateType=1)
		begin	
			select convert(varchar(8),CreateTime,112) as CreateTime,sum(Quantity)as TotalNum from GoodsDoc 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9 and DocType=2 
			group by  convert(varchar(8),CreateTime,112)		
		end
		--����ͳ��
		else if(@DateType=2)
		begin
			select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,sum(Quantity)as TotalNum from GoodsDoc 
			where ClientID=@ClientID and  CreateTime between @BeginTime and @EndTime and Status<>9 and DocType=2 
			group by   datename(year,CreateTime)+datename(week,CreateTime)		
				
		end
		--����ͳ��
		else if(@DateType=3)
		begin	
			select convert(varchar(6),CreateTime,112) as CreateTime,sum(Quantity)as TotalNum from GoodsDoc 
			 where ClientID=@ClientID and CreateTime between @BeginTime and @EndTime  and Status<>9 and DocType=2 
			 group by   convert(varchar(6),CreateTime,112)	
		end
	end
end
GO