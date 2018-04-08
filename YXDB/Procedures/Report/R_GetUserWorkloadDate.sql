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
调试记录： exec R_GetUserWorkloadDate '2016-1-1','2018-1-1',1,'','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserWorkloadDate]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@DocType int=1,
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
	declare @SqlText nvarchar(4000)
	create table #ResultDate(UserID nvarchar(64),CutQuantity int,SewnQuantity int,SewnReturn int,DocType int,Status int)
	create table #TempData(OwnerID nvarchar(64),Quantity int,DocType int)
	create table #UserID(UserID nvarchar(64))

	set @SqlText ='insert into #TempData select OwnerID, sum(Quantity),DocType  from GoodsDoc where ClientID='''+@ClientID+''' and (ProcessID is null or ProcessID='''')'

	set @SqlText +=' and CreateTime >= '''+@BeginTime+'''';

	set @SqlText +=' and CreateTime < '''+@EndTime+'''';

	--set @SqlText +=' and DocType = '+@DocType;

	if(@UserID<>'')
	begin
		set @SqlText +=' and OwnerID = '''+@UserID+''''
		insert into #ResultDate(UserID,CutQuantity,SewnQuantity,SewnReturn,DocType,Status)
		select UserID,0 ,0 ,0 ,@DocType  ,Status  from Users  where UserID=@UserID
	end
	else if(@TeamID<>'')
	begin
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and OwnerID in (select UserID from #UserID) '

		insert into #ResultDate(UserID,CutQuantity,SewnQuantity,SewnReturn,DocType,Status)
		select UserID,0 ,0 ,0 ,@DocType ,Status  from Users 
		where ClientID=@ClientID and UserID in (select UserID from #UserID)

	end
	else
	begin
		insert into #ResultDate(UserID,CutQuantity,SewnQuantity,SewnReturn,DocType,Status)
		select UserID,0 ,0 ,0 ,@DocType  ,Status  from Users  where ClientID=@ClientID
	end

	set @SqlText +=' group by OwnerID,DocType '

	exec (@SqlText)

	update u set CutQuantity=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID where d.DocType=1
	update u set SewnQuantity=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID where d.DocType=11
	update u set SewnReturn=d.Quantity from #ResultDate u join  #TempData d on u.UserID=d.OwnerID where d.DocType=6


	if(@DocType=1)
	begin
		select * from #ResultDate where CutQuantity>0 order by CutQuantity desc
	end
	else if(@DocType=11)
	begin
		select * from #ResultDate where SewnQuantity+SewnReturn>0 order by SewnQuantity desc
	end

 



 

