Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetOrderProductionRPT')
BEGIN
	DROP  Procedure  R_GetOrderProductionRPT
END

GO
/***********************************************************
过程名称： R_GetOrderProductionRPT
功能描述： 订单生产数据统计
参数说明：	 
编写日期： 2017/12/5
程序作者： Allen
调试记录： exec R_GetOrderProductionRPT '2016-1-1','2018-1-1','','','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetOrderProductionRPT]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@KeyWords nvarchar(200)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)

	set @SqlText =' select o.IntGoodsCode,o.OwnerID,o.CustomerName,SUM(g.Quantity) OrderQuantity,SUM(g.CutQuantity) CutQuantity,SUM(g.Complete) Complete,SUM(g.SendQuantity) SendQuantity ,o.FinalPrice 
					from Orders o join OrderGoods g on o.OrderID=g.OrderID where OrderType=2 and OrderStatus in (1,2) and o.ClientID='''+@ClientID+''''

	set @SqlText +=' and o.CreateTime >= '''+@BeginTime+'''';

	set @SqlText +=' and o.CreateTime < '''+@EndTime+'''';

	if(@KeyWords<>'')
	begin
		set @SqlText +=' and (o.IntGoodsCode like ''%'+@keyWords+'%''  or o.CustomerName like ''%'+@keyWords+'%'')'
	end

	if(@UserID<>'')
	begin
		set @SqlText +=' and o.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		set @SqlText +=' and o.OwnerID in (select UserID from #UserID) '
	end

	set @SqlText +=' group by o.IntGoodsCode,o.OwnerID,o.CustomerName,o.FinalPrice  '

	exec (@SqlText)

	