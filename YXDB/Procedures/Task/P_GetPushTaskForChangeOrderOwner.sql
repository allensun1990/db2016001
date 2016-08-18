Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTaskForChangeOrderOwner')
BEGIN
	DROP  Procedure  P_GetPushTaskForChangeOrderOwner
END

GO
/***********************************************************
过程名称： P_GetPushTaskForChangeOrderOwner
功能描述： 获取订单更换负责人的推送push
参数说明：	 
编写日期： 2016/8/16
程序作者： MU
调试记录：  exec P_GetPushTaskForChangeOrderOwner '2ef3ce07-1e21-4a46-9706-02ade5ccf7c9'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskForChangeOrderOwner
@OrderID nvarchar(64)
as
select o.OrderCode as Title,o.PlanTime as EndTime,u.ProjectID as OpenID,u.ClientID from orders as o,UserAccounts as u
where o.OwnerID=u.UserID and o.OrderID=@OrderID and
u.AccountType=4 and u.ProjectID<>''
		 





