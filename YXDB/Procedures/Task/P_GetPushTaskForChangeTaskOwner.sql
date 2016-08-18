Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTaskForChangeTaskOwner')
BEGIN
	DROP  Procedure  P_GetPushTaskForChangeTaskOwner
END

GO
/***********************************************************
过程名称： P_GetPushTaskForChangeTaskOwner
功能描述： 获取任务更换负责人的推送push
参数说明：	 
编写日期： 2016/8/18
程序作者： MU
调试记录：  exec P_GetPushTaskForChangeTaskOwner '2ef3ce07-1e21-4a46-9706-02ade5ccf7c9'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskForChangeTaskOwner
@TaskID nvarchar(64)
as
select t.Title,t.EndTime,u.ProjectID as OpenID,u.ClientID from ordertask as t,UserAccounts as u
where t.OwnerID=u.UserID and t.TaskID=@TaskID and
u.AccountType=4 and u.ProjectID<>''
		 





