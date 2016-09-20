Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetAgentOrderByID')
BEGIN
	DROP  Procedure  P_GetAgentOrderByID
END

GO
/***********************************************************
过程名称： P_GetAgentOrderByID
功能描述： 获取代理商订单详情
参数说明：	 
编写日期： 2015/11/22
程序作者： Allen
调试记录： exec P_GetAgentOrderByID 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetAgentOrderByID]
	@OrderID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
declare @CustomerID nvarchar(64),@Status int 

select @CustomerID=CustomerID,@Status=Status from Orders where OrderID=@OrderID and ClientID=@ClientID

select * from AgentsOrders where OrderID=@OrderID and ClientID=@ClientID

if(@Status=0)
begin
	select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark ,p.ProductName,u.UnitID,u.UnitName,s.Price,d.Imgs 
	from ShoppingCart s 
	join ProductDetail d on d.ProductDetailID=s.ProductDetailID
	join Products p  on s.ProductID=p.ProductID
	join ProductUnit u on s.UnitID=u.UnitID
	where s.[GUID]=@OrderID and s.OrderType=21
end
else
begin
	select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark ,p.ProductName,p.UnitID,p.UnitName,s.Price,s.TotalMoney,d.Imgs ,s.ApplyQuantity,s.ReturnQuantity
	from AgentsOrderDetail s 
	join ProductDetail d on d.ProductDetailID=s.ProductDetailID
	join Products p  on s.ProductID=p.ProductID
	where s.OrderID=@OrderID 
end

