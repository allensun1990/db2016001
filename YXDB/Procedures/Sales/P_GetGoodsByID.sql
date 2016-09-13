Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetGoodsByID')
BEGIN
	DROP  Procedure  P_GetGoodsByID
END

GO
/***********************************************************
过程名称： P_GetGoodsByID
功能描述： 获取客户订单详情
参数说明：	 
编写日期： 2016/9/2
程序作者： MU
调试记录： exec P_GetGoodsByID 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetGoodsByID]
	@GoodsID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
select * from Goods as g,orders as o where 
g.GoodsID=o.GoodsID and o.ordertype=1 and 
g.GoodsID=@GoodsID and g.ClientID=@ClientID



