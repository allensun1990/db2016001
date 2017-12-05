Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetUserTaskQuantity')
BEGIN
	DROP  Procedure  R_GetUserTaskQuantity
END

GO
/***********************************************************
过程名称： R_GetUserTaskQuantity
功能描述： 获取员工任务数
参数说明：	 
编写日期： 2017/11/30
程序作者： Allen
调试记录： exec R_GetUserTaskQuantity '2016-1-1','2018-1-1','','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserTaskQuantity]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)
	create table #ResultDate(UserID nvarchar(64),Status int,NoBeginQuantity int,Processing int,OverQuantity int,ExpiredProcessing int,ExpiredOver int)

	if(@UserID<>'')
	begin
		insert into #ResultDate(UserID,Status,NoBeginQuantity,Processing,OverQuantity,ExpiredProcessing,ExpiredOver)
		select UserID,Status,0,0,0,0,0  from Users  where UserID=@UserID
	end
	else if(@TeamID<>'')
	begin

		insert into #ResultDate(UserID,Status,NoBeginQuantity,Processing,OverQuantity,ExpiredProcessing,ExpiredOver)
		select UserID,Status,0,0,0,0,0  from Users 
		where ClientID=@ClientID and UserID in (select UserID from #UserID)

	end
	else
	begin
		insert into #ResultDate(UserID,Status,NoBeginQuantity,Processing,OverQuantity,ExpiredProcessing,ExpiredOver)
		select UserID,Status,0,0,0,0,0  from Users   where ClientID=@ClientID
	end

	--存放临时数据
	select OwnerID,FinishStatus,EndTime,CompleteTime into #TempTask from OrderTask 
	where ClientID=@ClientID  and CreateTime between @BeginTime and @EndTime and Status=1

	--未接受
	update u set NoBeginQuantity=d.Quantity from #ResultDate u 
	join  (select OwnerID,COUNT(0) Quantity from #TempTask where FinishStatus=0 group by OwnerID) d on u.UserID=d.OwnerID
	
	--进行中
	update u set Processing=d.Quantity from #ResultDate u 
	join  (select OwnerID,COUNT(0) Quantity from #TempTask where FinishStatus=1 group by OwnerID) d on u.UserID=d.OwnerID

	--完成总数
	update u set OverQuantity=d.Quantity from #ResultDate u 
	join  (select OwnerID,COUNT(0) Quantity from #TempTask where FinishStatus=2 group by OwnerID) d on u.UserID=d.OwnerID
	
	--超期总数
	update u set ExpiredProcessing=d.Quantity from #ResultDate u 
	join  (select OwnerID,COUNT(0) Quantity from #TempTask where FinishStatus=1 and  getdate()>EndTime group by OwnerID) d on u.UserID=d.OwnerID
	
	--超期完成
	update u set ExpiredOver=d.Quantity from #ResultDate u 
	join  (select OwnerID,COUNT(0) Quantity from #TempTask where FinishStatus=2 and CompleteTime>EndTime group by OwnerID) d on u.UserID=d.OwnerID
	

	select * from #ResultDate where  NoBeginQuantity+Processing+OverQuantity>0 order by NoBeginQuantity+Processing+OverQuantity desc


 

