Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrderBillByID')
BEGIN
	DROP  Procedure  P_GetOrderBillByID
END

GO
/***********************************************************
过程名称： P_GetOrderBillByID
功能描述： 获取应收账款明细
参数说明：	 
编写日期： 2015/11/19
程序作者： Allen
调试记录： exec P_GetOrderBillByID 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrderBillByID]
	@BillingID nvarchar(64),
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
	
	select @BillingID=BillingID from Billing where BillingID=@BillingID or OrderID=@BillingID

	select * from Billing where BillingID=@BillingID and AgentID=@AgentID

	select * from BillingPay where BillingID=@BillingID and AgentID=@AgentID and Status<>9 order by PayTime desc,AutoID desc

	select * from BillingInvoice  where BillingID=@BillingID and AgentID=@AgentID and Status<>9 order by AutoID desc