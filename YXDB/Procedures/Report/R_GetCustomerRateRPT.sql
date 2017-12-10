Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetCustomerRateRPT')
BEGIN
	DROP  Procedure  R_GetCustomerRateRPT
END

GO
/***********************************************************
过程名称： R_GetCustomerRateRPT
功能描述： 客户需求单转化率统计
参数说明：	 
编写日期： 2017/12/7
程序作者： Allen
调试记录： exec R_GetCustomerRateRPT '2016-1-1','2018-1-1','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetCustomerRateRPT]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@KeyWords nvarchar(200)='',
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)

	select OrderID,CustomerID,CustomerName,case OrderStatus when 1 then 1 when 2 then 1 else 0 end DYCount,0 DHCount into  #Result from Orders 
	where ClientID=@ClientID and OrderType=1 and OrderStatus!=9 and CreateTime between @BeginTime and @EndTime

	update #Result set DHCount=1 where OrderID in
	(select OriginalID from Orders  where OrderType=2 and OrderStatus in (1,2) and OriginalID in(select OrderID from #Result) group by OriginalID)

	select CustomerID,CustomerName,Count(OrderID) DemandCount,sum(DYCount) DYCount,sum(DHCount) DHCount from #Result 
	group by CustomerID,CustomerName
	order by Count(OrderID) desc



	