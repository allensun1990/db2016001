Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetKanbanRPT')
BEGIN
	DROP  Procedure  R_GetKanbanRPT
END

GO
/***********************************************************
过程名称： R_GetKanbanRPT
功能描述： 核心看板
参数说明：	 
编写日期： 2018/3/4
程序作者： Allen
调试记录： exec R_GetKanbanRPT '2016-1-1','2018-1-1','2016-1-1','2018-1-1','2016-1-1','2018-1-1','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetKanbanRPT]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@TodayBeginTime nvarchar(50)='',
	@TodayEndTime nvarchar(50)='',
	@LastBeginTime nvarchar(50)='',
	@LastEndTime nvarchar(50)='',
	@ClientID nvarchar(64)
AS


	create table #ResultDate(DataType nvarchar(64),Total decimal(18,2),Today decimal(18,2),LastDay decimal(18,2))
	insert into #ResultDate values('customerItem',0,0,0)
	insert into #ResultDate values('needItem',0,0,0)
	insert into #ResultDate values('dyItem',0,0,0)
	insert into #ResultDate values('dhItem',0,0,0)
	insert into #ResultDate values('taskItem',0,0,0)
	insert into #ResultDate values('moneyItem',0,0,0)
	insert into #ResultDate values('sendItem',0,0,0)

	update #ResultDate set Total=(select count(0) from Customer where ClientID=@ClientID and Status<>9 and CreateTime between @BeginTime and @EndTime) ,
	Today=(select count(0) from Customer where ClientID=@ClientID and Status<>9 and CreateTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select count(0) from Customer where ClientID=@ClientID and Status<>9 and CreateTime between @LastBeginTime and @LastEndTime) 
	where DataType ='customerItem'

	update #ResultDate set Total=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and CreateTime between @BeginTime and @EndTime) ,
	Today=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and CreateTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and CreateTime between @LastBeginTime and @LastEndTime) 
	where DataType ='needItem'

	update #ResultDate set Total=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and OrderType=1 and OrderStatus in (1,2) and OrderTime between @BeginTime and @EndTime) ,
	Today=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and OrderType=1 and OrderStatus in (1,2) and OrderTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and OrderType=1 and OrderStatus in (1,2) and OrderTime between @LastBeginTime and @LastEndTime) 
	where DataType ='dyItem'

	update #ResultDate set Total=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and OrderType=2 and OrderStatus in (1,2) and OrderTime between @BeginTime and @EndTime) ,
	Today=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and OrderType=2 and OrderStatus in (1,2) and OrderTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select count(0) from Orders where ClientID=@ClientID and Status<>9 and OrderType=2 and OrderStatus in (1,2) and OrderTime between @LastBeginTime and @LastEndTime) 
	where DataType ='dhItem'

	update #ResultDate set Total=(select count(0) from OrderTask where ClientID=@ClientID and Status<>9 and CreateTime between @BeginTime and @EndTime) ,
	Today=(select count(0) from OrderTask where ClientID=@ClientID and Status<>9 and CreateTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select count(0) from OrderTask where ClientID=@ClientID and Status<>9 and CreateTime between @LastBeginTime and @LastEndTime) 
	where DataType ='taskItem'

	update #ResultDate set Total=(select sum(PayMoney) from BillingPay where ClientID=@ClientID and Status<>9 and [Type]=2 and PayTime between @BeginTime and @EndTime) ,
	Today=(select sum(PayMoney) from BillingPay where ClientID=@ClientID and Status<>9 and [Type]=2 and PayTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select sum(PayMoney) from BillingPay where ClientID=@ClientID and Status<>9 and [Type]=2 and PayTime between @LastBeginTime and @LastEndTime) 
	where DataType ='moneyItem'

	update #ResultDate set Total=(select sum(Quantity) from GoodsDoc where ClientID=@ClientID and Status<>9 and DocType=2 and CreateTime between @BeginTime and @EndTime) ,
	Today=(select sum(Quantity) from GoodsDoc where ClientID=@ClientID and Status<>9  and DocType=2  and CreateTime between @TodayBeginTime and @TodayEndTime) ,
	LastDay=(select sum(Quantity) from GoodsDoc where ClientID=@ClientID and Status<>9  and DocType=2  and CreateTime between @LastBeginTime and @LastEndTime) 
	where DataType ='sendItem'

	select DataType,isnull(Total,0) Total,isnull(Today,0) Today,isnull(LastDay,0) LastDay from #ResultDate
	drop table #ResultDate

	



	