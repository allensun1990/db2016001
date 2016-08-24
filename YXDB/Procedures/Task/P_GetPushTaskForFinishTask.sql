Use IntFactory
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
declare @orderid nvarchar(64),@sort int,@nexttaskid nvarchar(64),
@pretitle nvarchar(200),@title nvarchar(200),@ownerid nvarchar(64),@goodsname nvarchar(200)='',@ordertype int=1
declare @tmp table(TaskID nvarchar(64),PreTitle nvarchar(100),Title nvarchar(100),OwnerID nvarchar(64),GoodsName nvarchar(100),OrderType int )

select @orderid=OrderID,@pretitle=Title,@sort=Sort from OrderTask
where TaskID=@TaskID

select @goodsname=goodsname,@ordertype=ordertype from Orders
where OrderID=@orderid

select @ownerid=OwnerID,@title=Title,@nexttaskid=taskid from OrderTask
where OrderID=@orderid and Sort=@sort+1 and FinishStatus<>2

if(@ownerid<>'')
begin
	insert into @tmp select @nexttaskid,@pretitle,@title,@ownerid,@goodsname,@ordertype

	select u.ProjectID as OpenID,u.ClientID, t.* from @tmp as t left join  UserAccounts as u on  t.OwnerID=u.UserID and u.AccountType=4 and u.ProjectID<>''
end
else 
	select * from @tmp

if(not exists( select taskid from ordertask where orderid=@orderid and status<>8  and FinishStatus<>2))
begin
	declare @tmp2 table(OrderCode nvarchar(100),OwnerID nvarchar(64),ClientID nvarchar(64),Status int)

	insert into @tmp2 select OrderCode,OwnerID,ClientID,Status from orders as o where o.OrderID=@orderid and o.OrderStatus<>2

	select  o.*,u.ProjectID as OpenID  from @tmp2 as o left join UserAccounts u  on o.OwnerID=u.UserID and u.AccountType=4 and u.ProjectID<>''
end

		 





