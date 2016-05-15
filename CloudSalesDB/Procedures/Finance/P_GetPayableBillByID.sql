Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPayableBillByID')
BEGIN
	DROP  Procedure  P_GetPayableBillByID
END

GO
/***********************************************************
过程名称： P_GetPayableBillByID
功能描述： 获取应付账款
参数说明：	 
编写日期： 2015/11/18
程序作者： Allen
调试记录： exec P_GetPayableBillByID 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetPayableBillByID]
	@BillingID nvarchar(64),
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS
	
	select * from StorageBilling where BillingID=@BillingID and AgentID=@AgentID

	select * from StorageBillingPay where BillingID=@BillingID and AgentID=@AgentID and Status<>9 order by PayTime desc

	select * from StorageBillingInvoice  where BillingID=@BillingID and AgentID=@AgentID and Status<>9 order by AutoID desc