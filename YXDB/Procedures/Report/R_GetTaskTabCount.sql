Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetTaskTabCount')
BEGIN
	DROP  Procedure  R_GetTaskTabCount
END

GO
/***********************************************************
过程名称： R_GetTaskTabCount
功能描述： 订单tab数量
参数说明：	 
编写日期： 2018/6/12
程序作者： Allen
调试记录： exec R_GetTaskTabCount '',1,'5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetTaskTabCount]
	@UserID nvarchar(64)='',
	@SearchType int,
	@ClientID nvarchar(64)
AS

	create table #ResultDate(OrderType int,OrderStatus int,OrderQuantity int)

	if(@UserID is null or @UserID='')
	begin
		--未归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select 0,FinishStatus,count(0) OrderQuantity from OrderTask
		where Status=1 and ClientID=@ClientID
		group by FinishStatus 
		
	end
	else if(@SearchType=1)
	begin
		--未归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select 0,FinishStatus,count(0) OrderQuantity from OrderTask
		where Status=1 and TaskID in( select distinct TaskID from TaskMember where Status<>9 and MemberID=@UserID)
		group by FinishStatus 
	end
	else
	begin
		--未归档
		insert into #ResultDate(OrderType,OrderStatus,OrderQuantity) 
		select 0,FinishStatus,count(0) OrderQuantity from OrderTask
		where Status=1 and OwnerID =@UserID
		group by FinishStatus 
	end
	select * from #ResultDate
	drop table #ResultDate


 

