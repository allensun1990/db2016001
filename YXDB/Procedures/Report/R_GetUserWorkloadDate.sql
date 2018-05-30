Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetUserWorkloadDate')
BEGIN
	DROP  Procedure  R_GetUserWorkloadDate
END

GO
/***********************************************************
过程名称： R_GetUserWorkloadDate
功能描述： 获取员工工作量（裁片-车缝）
参数说明：	 
编写日期： 2016/8/27
程序作者： Allen
调试记录： exec R_GetUserWorkloadDate '2011-1-1','2018-11-1',11,'','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserWorkloadDate]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@DocType int=1,
	@UserID nvarchar(64)='',
	@KeyWords nvarchar(200)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
	declare @SqlText nvarchar(4000)
	create table #TempData(OwnerID nvarchar(64),OrderID nvarchar(64),Quantity int,DocType int)
	create table #UserID(UserID nvarchar(64))

	set @SqlText ='insert into #TempData select g.OwnerID, g.OrderID,sum(g.Quantity),g.DocType  from GoodsDoc g join Orders o on g.OrderID=o.OrderID where g.ClientID='''+@ClientID+''' and (g.ProcessID is null or g.ProcessID='''')'

	set @SqlText +=' and g.CreateTime >= '''+@BeginTime+'''';

	set @SqlText +=' and g.CreateTime < '''+@EndTime+'''';

	if(@KeyWords<>'')
	begin
		set @SqlText +=' and (o.IntGoodsCode like ''%'+@keyWords+'%''  or o.CustomerName like ''%'+@keyWords+'%'')'
	end

	if(@UserID<>'')
	begin
		set @SqlText +=' and g.OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and g.OwnerID in (select UserID from #UserID) '

	end
	set @SqlText +=' group by g.OwnerID,g.DocType,g.OrderID '

	exec (@SqlText)

	create table #ResultDate(UserID nvarchar(64),Quantity int,ReturnQuantity int,OrderID nvarchar(64))
	if(@DocType=1)
	begin
		select OwnerID UserID,sum(Quantity) Quantity from #TempData where DocType=1 group by OwnerID
	end
	else if(@DocType=11)
	begin
		insert into #ResultDate select OwnerID,0,0,OrderID from #TempData where DocType in(11,6) group by OwnerID,OrderID
		update u set Quantity=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID and u.OrderID=d.OrderID where d.DocType=11
		update u set ReturnQuantity=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID and u.OrderID=d.OrderID where d.DocType=6

		select o.*,r.Quantity,r.ReturnQuantity,r.UserID from #ResultDate r join 
		(select o.ClientID,o.EntrustClientID,o.CustomerID,o.CustomerName,o.OrderID,o.IntGoodsCode,SUM(g.Quantity) OrderQuantity,SUM(g.CutQuantity) CutQuantity,SUM(g.Complete) Complete,SUM(g.SendQuantity) SendQuantity 
		from Orders o join OrderGoods g on o.OrderID=g.OrderID where OrderType=2 and OrderStatus in (1,2) and o.OrderID in (select OrderID from #ResultDate)
		group by o.ClientID,o.EntrustClientID,o.CustomerID,o.CustomerName,o.IntGoodsCode,o.OrderID) o on r.OrderID=o.OrderID
		order by r.UserID
	end
	else if(@DocType=2)
	begin
		
		select OrderID,DocType,sum(Quantity) Quantity into #TempRPTData from #TempData where DocType in(2,22) group by OrderID,DocType

		insert into #ResultDate select '',0,0,OrderID from #TempRPTData where DocType in(2,22) group by OrderID
		update u set Quantity=d.Quantity from #ResultDate u join  #TempRPTData d on  u.OrderID=d.OrderID where d.DocType=2
		update u set ReturnQuantity=d.Quantity from #ResultDate u join  #TempRPTData d on  u.OrderID=d.OrderID where d.DocType=22

		select o.*,r.Quantity,r.ReturnQuantity,r.UserID from #ResultDate r join 
		(select o.ClientID,o.EntrustClientID,o.CustomerID,o.CustomerName,o.OrderID,o.IntGoodsCode,SUM(g.Quantity) OrderQuantity,SUM(g.CutQuantity) CutQuantity,SUM(g.Complete) Complete,SUM(g.SendQuantity) SendQuantity 
		from Orders o join OrderGoods g on o.OrderID=g.OrderID where OrderType=2 and OrderStatus in (1,2) and o.OrderID in (select OrderID from #ResultDate)
		group by o.ClientID,o.EntrustClientID,o.CustomerID,o.CustomerName,o.IntGoodsCode,o.OrderID) o on r.OrderID=o.OrderID
	end
	

	


 



 

