Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPushTaskByPreTaskID')
BEGIN
	DROP  Procedure  P_GetPushTaskByPreTaskID
END

GO
/***********************************************************
过程名称： P_GetPushTaskByPreTaskID
功能描述： 获取需push任务通过上级TaskID
参数说明：	 
编写日期： 2016/8/12
程序作者： MU
调试记录：  exec P_GetPushTaskByPreTaskID '2ef3ce07-1e21-4a46-9706-02ade5ccf7c9'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskByPreTaskID
@TaskID nvarchar(64)
as
declare @orderid nvarchar(64),@sort int,
@pretitle nvarchar(200),@title nvarchar(200),@onwerid nvarchar(64)

select @orderid=OrderID,@pretitle=Title,@sort=Sort from OrderTask
where TaskID=@TaskID

select @onwerid=OwnerID,@title=Title from OrderTask
where OrderID=@orderid and Sort=@sort+1 and FinishStatus<>2

if(@onwerid<>'')
	select ProjectID as OpenID,@pretitle as PreTitle,@title as Title,@onwerid as OnwerID from UserAccounts
	where UserID=@onwerid and AccountType=4 and ProjectID<>''
else 
	select ProjectID as OpenID,@pretitle as PreTitle,@title as Title,@onwerid as OnwerID from UserAccounts
	where 1=2

		 





