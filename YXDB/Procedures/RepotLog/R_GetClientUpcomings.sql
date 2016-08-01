Use IntFactory
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
调试记录： exec R_GetClientUpcomings  '','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetClientUpcomings]
@UserID nvarchar(64),
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
select 21,0,0,0 from Orders 
where OrderStatus=0  and ClientID=@ClientID and OwnerID=@UserID 
group by Status
having(COUNT(AutoID)>0)

--任务
insert into #Result(DocType,Status,SendStatus,ReturnStatus)
select 111,0,1,Count(AutoID) from OrderTask 
where FinishStatus=0 and OwnerID=@UserID and Status=1
group by FinishStatus
having(COUNT(AutoID)>0)

select * from #Result