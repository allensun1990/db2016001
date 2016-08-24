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
调试记录：  exec P_GetPushTaskForChangeOrderOwner '735935d3-0ac3-4cb3-bb71-97994beebc5b'
************************************************************/
CREATE PROCEDURE [dbo].P_GetPushTaskForChangeOrderOwner
@OrderID nvarchar(64)
as
declare @tmp table(Title nvarchar(100),EndTime datetime,OwnerID nvarchar(64),ClientID nvarchar(64),GoodsName nvarchar(100),OrderType int )

insert into  @tmp select o.OrderCode ,o.PlanTime ,o.OwnerID,ClientID,o.goodsname,o.ordertype from orders as o
where  o.OrderID=@OrderID and o.OrderStatus<>2 

if(exists(select OwnerID from @tmp))
	select o.*,u.ProjectID as OpenID from @tmp as o left join UserAccounts as u on o.OwnerID=u.UserID and u.AccountType=4 and u.ProjectID<>''

		 





