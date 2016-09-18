Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCategory')
BEGIN
	DROP  Procedure  P_UpdateCategory
END

GO
/***********************************************************
过程名称： P_UpdateCategory
功能描述： 编辑产品分类
参数说明：	 
编写日期： 2015/7/15
程序作者： Allen
调试记录： exec P_UpdateCategory 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateCategory]
@CategoryID nvarchar(64),
@CategoryName nvarchar(200),
@CategoryCode nvarchar(200),
@AttrList nvarchar(4000),
@SaleAttr nvarchar(4000),
@AttrListStr nvarchar(4000)='',
@SaleAttrStr nvarchar(4000)='',
@Status int,
@Description nvarchar(4000),
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output 
AS

begin tran

set @Result=0

if exists(select AutoID from Category where ClientID=@ClientID and CategoryCode=@CategoryCode and CategoryID<>@CategoryID and Status<>9)
begin
	set @Result=2
	rollback tran
	return
end

declare @Err int, @OldAttr nvarchar(4000),@OldSales nvarchar(4000),@sql nvarchar(4000),@AutoID int=1,@AttrID nvarchar(64)
set @Err=0

select @OldAttr=AttrList,@OldSales=SaleAttr from Category where CategoryID=@CategoryID

Update Category set CategoryName=@CategoryName,CategoryCode=@CategoryCode,Status=@Status,AttrList=@AttrList,AttrListStr=@AttrListStr,
					SaleAttr=@SaleAttr,SaleAttrStr=@SaleAttrStr,Description=@Description,UpdateTime=getdate() 
where CategoryID=@CategoryID

set @Err+=@@error

if(@AttrList<>@OldAttr)
begin
	Update CategoryAttr set Status=9,UpdateTime=getdate() where CategoryID=@CategoryID and Type=1 -- and CHARINDEX(AttrID,@AttrList)=0

	create table #TempTableAttr(ID int identity(1,1),Value nvarchar(4000))
	set @sql='select col='''+ replace(@AttrList,',',''' union all select ''')+''''
	insert into #TempTableAttr exec (@sql)
	while exists(select ID from #TempTableAttr where ID=@AutoID)
	begin
		select @AttrID=Value from #TempTableAttr where ID=@AutoID
		if(@AttrID is not null and @AttrID<>'')
		begin
			insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime,Sort)
			values (@CategoryID,@AttrID,1,1,@UserID,getdate(),@AutoID)

		end
		set @AutoID+=1
	end
end

if(@SaleAttr<>@OldSales)
begin
	Update CategoryAttr set Status=9,UpdateTime=getdate() where CategoryID=@CategoryID and Type=2 --and CHARINDEX(AttrID,@SaleAttr)=0
	set @AutoID=1
	create table #TempTable(ID int identity(1,1),Value nvarchar(4000))
	set @sql='select col='''+ replace(@SaleAttr,',',''' union all select ''')+''''
	insert into #TempTable exec (@sql)
	while exists(select ID from #TempTable where ID=@AutoID)
	begin
		select @AttrID=Value from #TempTable where ID=@AutoID
		if(@AttrID is not null and @AttrID<>'')
		begin
			insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime,Sort)
			values (@CategoryID,@AttrID,1,2,@UserID,getdate(),@AutoID)

		end
		set @AutoID+=1
	end
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end