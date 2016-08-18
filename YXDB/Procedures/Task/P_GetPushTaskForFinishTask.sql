﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTaskForFinishTask')
BEGIN
	DROP  Procedure  P_GetPushTaskForFinishTask
END

GO
/***********************************************************
过程名称： P_GetPushTaskForFinishTask
功能描述： 获取任务完成通知下级任务的推送push
参数说明：	 
编写日期： 2016/8/12
程序作者： MU
调试记录：  exec P_GetPushTaskForFinishTask '1085e427-130c-4758-ad1d-2ce3a87a3266'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskForFinishTask
@TaskID nvarchar(64)
as
declare @orderid nvarchar(64),@sort int,
@pretitle nvarchar(200),@title nvarchar(200),@ownerid nvarchar(64)

select @orderid=OrderID,@pretitle=Title,@sort=Sort from OrderTask
where TaskID=@TaskID

select @ownerid=OwnerID,@title=Title from OrderTask
where OrderID=@orderid and Sort=@sort+1 and FinishStatus<>2

if(@ownerid<>'')
	select ProjectID as OpenID,@pretitle as PreTitle,@title as Title,@ownerid as OwnerID,ClientID from UserAccounts
	where UserID=@ownerid and AccountType=4 and ProjectID<>''
else 
	select ProjectID as OpenID,@pretitle as PreTitle,@title as Title,@ownerid as OwnerID,ClientID from UserAccounts
	where 1=2

		 




