Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTasksByOrderID')
BEGIN
	DROP  Procedure  P_GetPushTasksByOrderID
END

GO
/***********************************************************
过程名称： P_GetPushTasksByOrderID
功能描述： 获取需push任务列表通过OrderID
参数说明：	 
编写日期： 2016/8/12
程序作者： MU
调试记录：  exec P_GetPushTasksByOrderID '2ef3ce07-1e21-4a46-9706-02ade5ccf7c9'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTasksByOrderID
@OrderID nvarchar(64)
as
declare @PlanTime datetime
select @PlanTime=PlanTime from orders where OrderID=@OrderID

select u.ProjectID as OpenID,t.Title,t.OwnerID,@PlanTime as EndTime  from OrderTask as t,UserAccounts u
where t.OwnerID=u.UserID and  t.OrderID=@OrderID and
 u.AccountType=4 and u.ProjectID<>''
 order by t.sort asc

		 





