Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetUserWorkloadDate')
BEGIN
	DROP  Procedure  R_GetUserWorkloadDate
END

GO
/***********************************************************
过程名称： R_GetUserWorkloadDate
功能描述： 获取员工工作量（裁片-车缝）
参数说明：	 
编写日期： 2016/8/27
程序作者： Allen
调试记录： exec R_GetUserWorkloadDate 4,'2016-1-1','2017-1-1','','','2fb14a22-c6a0-4de6-830c-b95624dfdee4'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserWorkloadDate]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)
	create table #ResultDate(UserID nvarchar(64),CutQuantity int,SewnQuantity int,SewnReturn int,TotalQuantity int,Status int)
	create table #TempData(OwnerID nvarchar(64),Quantity int,DocType int)
	create table #UserID(UserID nvarchar(64))

	set @SqlText ='insert into #TempData select OwnerID,sum(Quantity) Quantity,DocType  from GoodsDoc '
	set @SqlText+=' where  ClientID='''+@ClientID+''''

	if(@BeginTime<>'')
		set @SqlText +=' and CreateTime >= '''+@BeginTime+' 0:00:00''';

	if(@EndTime<>'')
		set @SqlText +=' and CreateTime <= '''+@EndTime+' 23:59:59''';

	if(@UserID<>'')
	begin
		set @SqlText +=' and OwnerID = '''+@UserID+''''
		insert into #ResultDate(UserID,CutQuantity,SewnQuantity,SewnReturn,TotalQuantity,Status)
		select UserID,0 ,0 ,0 ,0  ,Status  from Users  where UserID=@UserID
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and OwnerID in (select UserID from #UserID) '

		insert into #ResultDate(UserID,CutQuantity,SewnQuantity,SewnReturn,TotalQuantity,Status)
		select UserID,0 ,0 ,0 ,0  ,Status  from Users 
		where ClientID=@ClientID and UserID in (select UserID from #UserID)

	end
	else
	begin
		insert into #ResultDate(UserID,CutQuantity,SewnQuantity,SewnReturn,TotalQuantity,Status)
		select UserID,0 ,0 ,0 ,0  ,Status  from Users  where ClientID=@ClientID
	end

	set @SqlText +=' group by OwnerID,DocType '

	exec (@SqlText)

	update u set CutQuantity=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID where d.DocType=1
	update u set SewnQuantity=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID where d.DocType=11
	update u set SewnReturn=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID where d.DocType=6
	
	update #ResultDate set TotalQuantity=CutQuantity+SewnQuantity-SewnReturn

	select * from #ResultDate where Status=1 or TotalQuantity>0 order by TotalQuantity desc


 

