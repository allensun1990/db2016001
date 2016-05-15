Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrderBaseInfoByID')
BEGIN
	DROP  Procedure  P_GetOrderBaseInfoByID
END

GO
/***********************************************************
过程名称： P_GetOrderBaseInfoByID
功能描述： 获取客户订单基本信息
参数说明：	 
编写日期： 2016/3/25
程序作者： MU
调试记录： exec P_GetOrderBaseInfoByID 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrderBaseInfoByID]
	@OrderID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS

select * from Orders where OrderID=@OrderID and ClientID=@ClientID

select s.AutoID,s.ProductDetailID,s.ProductID,s.Quantity,s.Remark ,s.ProductName,s.Loss,s.UnitID,s.Price,
s.TotalMoney,s.Imgs ,s.ApplyQuantity,s.ReturnQuantity, s.DetailsCode, s.ProductCode,ProductImage
from OrderDetail s where s.OrderID=@OrderID 

