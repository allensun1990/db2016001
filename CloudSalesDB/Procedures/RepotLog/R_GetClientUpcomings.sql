Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientUpcomings')
BEGIN
	DROP  Procedure  R_GetClientUpcomings
END

GO
/***********************************************************
过程名称： R_GetClientUpcomings
功能描述： 公司待办事件
参数说明：	 
编写日期： 2015/12/22
程序作者： Allen
调试记录： exec R_GetClientUpcomings '8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetClientUpcomings]
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS

create table #Result(DocType int,Status int,SendStatus int, ReturnStatus int)

--单据
insert into #Result(DocType,Status,SendStatus,ReturnStatus)
select DocType,0,0,0 from StorageDoc 
where Status < 2 and ClientID=@ClientID
group by DocType
having(COUNT(AutoID)>0)

--订单
insert into #Result(DocType,Status,SendStatus,ReturnStatus)
select 21,2,SendStatus,ReturnStatus from AgentsOrders 
where Status=2 and (ReturnStatus=1 or SendStatus<2) and ClientID=@ClientID
group by SendStatus,ReturnStatus
having(COUNT(AutoID)>0)

--账单
insert into #Result(DocType,Status,SendStatus,ReturnStatus)
select 111,PayStatus,InvoiceStatus,0 from Billing 
where Status=1 and ClientID=@ClientID and AgentID=@AgentID
group by PayStatus,InvoiceStatus
having(COUNT(AutoID)>0)

select * from #Result