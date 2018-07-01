Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrderByID')
BEGIN
	DROP  Procedure  P_GetOrderByID
END

GO
/***********************************************************
过程名称： P_GetOrderByID
功能描述： 获取客户订单详情
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_GetOrderByID 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrderByID]
	@OrderID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS

select * from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

select * from OrderDetail where OrderID=@OrderID 

select * from OrderGoods where OrderID=@OrderID order by YRemark,Sort 

select * from OrderTask where OrderID=@OrderID order by Sort

select * from OrderAttrs where OrderID=@OrderID order by Sort

select * from OrderMember where OrderID=@OrderID and Status=1


