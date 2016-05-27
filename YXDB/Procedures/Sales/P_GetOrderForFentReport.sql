Use IntFactory_dev
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
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
declare @CustomerID nvarchar(64),@Status int ,@ProcessID nvarchar(64)

select @CustomerID=CustomerID,@Status=Status,@ProcessID=ProcessID from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

select * from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

select * from Customer where CustomerID=@CustomerID 

select d.*,p.MobileTele as ProviderMobile,p.Address as ProviderAddress,p.Name as ProviderName from OrderDetail as d left join Providers as p on d.ProdiverID=p.ProviderID
where d.OrderID=@OrderID

select * from OrderTask where OrderID=@OrderID and ProcessID=@ProcessID order by Sort

Select * from OrderCosts where OrderID=@OrderID and Status=1



