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
调试记录：  exec P_GetPushTaskForChangeTaskOwner '9ccdf558-0e31-4b35-9308-06ae26897f56'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskForChangeTaskOwner
@TaskID nvarchar(64)
as
declare @goodsname nvarchar(200)='',@ordertype int=1
declare @tmp table(Title nvarchar(100),EndTime datetime,OwnerID nvarchar(64),ClientID nvarchar(64),GoodsName nvarchar(100),OrderType int )

select @goodsname=o.goodsname, @ordertype=o.ordertype from orders as o ,ordertask as t
where o.orderid=t.orderid

insert into @tmp select Title,EndTime,OwnerID,ClientID,@goodsname,@ordertype from ordertask where TaskID=@TaskID and FinishStatus<>2

if(exists(select OwnerID from @tmp))
	select t.*,u.ProjectID as OpenID from @tmp as t left join UserAccounts as u on t.OwnerID=u.UserID and u.AccountType=4 and u.ProjectID<>''
else
	select * from @tmp
		 





