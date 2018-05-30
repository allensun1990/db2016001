Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetUserLoadDetailByOrderID')
BEGIN
	DROP  Procedure  R_GetUserLoadDetailByOrderID
END

GO
/***********************************************************
过程名称： R_GetUserLoadDetailByOrderID
功能描述： 获取员工工作量明细
参数说明：	 
编写日期： 2018/5/1
程序作者： Allen
调试记录： exec R_GetUserLoadDetailByOrderID '2011-1-1','2018-11-1',11,'','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserLoadDetailByOrderID]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@DocType int=1,
	@UserID nvarchar(64)='',
	@OrderID nvarchar(64)=''
AS
	
	if(@UserID<>'')
	begin
		select g.OwnerID UserID,o.OrderID,o.Quantity OrderQuantity,o.CutQuantity,o.Complete,o.SendQuantity,o.Remark,isnull(SUM(gd.Quantity),0) Quantity,isnull(SUM(gd.ReturnQuantity),0) ReturnQuantity
		from OrderGoods o join GoodsDoc g on o.OrderID=g.OrderID  left join GoodsDocDetail gd 
		on g.DocID=gd.DocID and o.GoodsDetailID=gd.GoodsDetailID
		where g.OrderID=@OrderID and g.DocType=@DocType and g.CreateTime between @BeginTime and @EndTime and g.OwnerID=@UserID
		group by g.OwnerID,o.OrderID,o.Quantity,o.CutQuantity,o.Complete,o.SendQuantity,o.Remark
	end
	else
	begin
		select o.OrderID,o.Quantity OrderQuantity,o.CutQuantity,o.Complete,o.SendQuantity,o.Remark,isnull(SUM(gd.Quantity),0) Quantity,isnull(SUM(gd.ReturnQuantity),0) ReturnQuantity
		from OrderGoods o join GoodsDoc g on o.OrderID=g.OrderID left join GoodsDocDetail gd 
		on g.DocID=gd.DocID and o.GoodsDetailID=gd.GoodsDetailID
		where g.OrderID=@OrderID and g.DocType=@DocType and g.CreateTime between @BeginTime and @EndTime 
		group by o.OrderID,o.Quantity,o.CutQuantity,o.Complete,o.SendQuantity,o.Remark
	end

	

	


 



 

