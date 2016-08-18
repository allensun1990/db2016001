Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTasksForNewOrder')
BEGIN
	DROP  Procedure  P_GetPushTasksForNewOrder
END

GO
/***********************************************************
过程名称： P_GetPushTasksForNewOrder
功能描述： 获取订单分解任务的推送push
参数说明：	 
编写日期： 2016/8/12
程序作者： MU
调试记录：  exec P_GetPushTasksForNewOrder '2ef3ce07-1e21-4a46-9706-02ade5ccf7c9'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTasksForNewOrder
@OrderID nvarchar(64)
as
declare @PlanTime datetime
select @PlanTime=PlanTime from orders where OrderID=@OrderID

select u.ProjectID as OpenID,t.Title,t.OwnerID,@PlanTime as EndTime,u.ClientID  from OrderTask as t,UserAccounts u
where t.OwnerID=u.UserID and  t.OrderID=@OrderID and
 u.AccountType=4 and u.ProjectID<>''
 order by t.sort asc

		 





