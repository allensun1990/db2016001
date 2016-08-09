Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrderForFentReport')
BEGIN
	DROP  Procedure  P_GetOrderForFentReport
END

GO
/***********************************************************
过程名称： P_GetOrderForFentReport
功能描述： 获取客户订单详情 用于打样报价单
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_GetOrderForFentReport 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrderForFentReport]
	@OrderID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS

select * from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

select d.*,p.MobileTele as ProviderMobileTele,p.Address as ProviderAddress,p.Name as ProviderName,p.CityCode as ProviderCityCode from OrderDetail as d left join Providers as p on d.ProviderID=p.ProviderID
where d.OrderID=@OrderID

select * from OrderTask where OrderID=@OrderID order by Sort

Select * from OrderCosts where OrderID=@OrderID and Status=1



