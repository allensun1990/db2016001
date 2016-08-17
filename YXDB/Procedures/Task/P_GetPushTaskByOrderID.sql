Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTaskByOrderID')
BEGIN
	DROP  Procedure  P_GetPushTaskByOrderID
END

GO
/***********************************************************
过程名称： P_GetPushTaskByOrderID
功能描述： 获取需push任务通过OrderID
参数说明：	 
编写日期： 2016/8/16
程序作者： MU
调试记录：  exec P_GetPushTaskByOrderID '2ef3ce07-1e21-4a46-9706-02ade5ccf7c9'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskByOrderID
@OrderID nvarchar(64)
as
select o.OrderID as Title,o.PlanTime as EndTime,u.ProjectID as OpenID,u.ClientID from orders as o,UserAccounts as u
where o.OwnerID=u.UserID and o.OrderID=@OrderID and
u.AccountType=4 and u.ProjectID<>''
		 





