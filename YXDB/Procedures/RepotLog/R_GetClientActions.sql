Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientActions')
BEGIN
	DROP  Procedure  R_GetClientActions
END

GO
/***********************************************************
过程名称： R_GetClientActions
功能描述： 首页事项
参数说明：	 
编写日期： 2016/3/10
程序作者： Allen
调试记录：  declare @CustomerCount int,@OrderCount int,@TotalMoney decimal(18,4)
			exec R_GetClientActions '2016-3-8 00:00:00','b00e97c6-1f93-4f61-aea1-74845af9cf28',@CustomerCount output,@OrderCount output,@TotalMoney output
			select @CustomerCount,@OrderCount,@TotalMoney
************************************************************/
CREATE PROCEDURE [dbo].[R_GetClientActions]
@DateTime datetime,
@ClientID nvarchar(64),
@CustomerCount int output,
@OrderCount int output,
@TotalMoney decimal(18,4) output
AS

set @TotalMoney=0

select @CustomerCount =count(0) from Customer where ClientID=@ClientID and CreateTime between DATEADD(week,-1,@DateTime) and @DateTime

select OrderType,case Status when 0 then 0 when 3 then 2 when 7 then 2 else 1 end Status,ClientID,EntrustClientID,case OrderType when 1 then FinalPrice else TotalMoney end TotalMoney into #TempOrder from Orders 
where (ClientID=@ClientID or EntrustClientID=@ClientID) and Status<>9 and CreateTime between DATEADD(week,-1,@DateTime) and @DateTime

select @OrderCount=count(0),@TotalMoney=isnull(sum(TotalMoney),0) from #TempOrder

create table #Result(ObjectType int,OrderType int,Status int ,OrderCount int)


insert into #Result select 6,OrderType,Status,count(0) from #TempOrder where ClientID=@ClientID and EntrustClientID='' group by OrderType,Status
insert into #Result select 5,OrderType,Status,count(0) from #TempOrder where ClientID=@ClientID and EntrustClientID<>'' group by OrderType,Status
insert into #Result select 4,OrderType,Status,count(0) from #TempOrder where EntrustClientID=@ClientID group by OrderType,Status

select * from #Result
