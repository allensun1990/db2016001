Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertCategory')
BEGIN
	DROP  Procedure  P_InsertCategory
END

GO
/***********************************************************
过程名称： P_InsertCategory
功能描述： 添加产品分类
参数说明：	 
编写日期： 2015/5/25
程序作者： Allen
调试记录： exec P_InsertCategory 
************************************************************/
CREATE PROCEDURE [dbo].[P_InsertCategory]
@CategoryCode nvarchar(200),
@CategoryName nvarchar(200),
@PID nvarchar(64),
@AttrList nvarchar(4000)='',
@SaleAttr nvarchar(4000)='',
@AttrListStr nvarchar(4000)='',
@SaleAttrStr nvarchar(4000)='',
@Status int,
@Description nvarchar(4000),
@CreateUserID nvarchar(64),
@ClientID nvarchar(64),
@CategoryID nvarchar(64) output,
@Result int output 
AS

begin tran

set @Result=0

if exists(select AutoID from Category where ClientID=@ClientID and CategoryCode=@CategoryCode and Status<>9)
begin
	set @Result=2
	rollback tran
	return
end

declare @Err int,@PIDList nvarchar(max),@Layers int=0,@sql nvarchar(4000),@AutoID int=1,@AttrID nvarchar(64)
set @Err=0
set @CategoryID=NEWID()
if(@PID is not null and @PID<>'')
begin
	select @PIDList=PIDList+','+@CategoryID,@Layers=Layers+1 from Category where CategoryID=@PID
end
else
begin
	set @PIDList=@CategoryID
	set @Layers=1
end

insert into Category(CategoryID,CategoryCode,CategoryName,PID,PIDList,Layers,SaleAttr,SaleAttrStr,AttrList,AttrListStr,Status,Description,CreateUserID,ClientID)
				values(@CategoryID,@CategoryCode,@CategoryName,@PID,@PIDList,@Layers,@SaleAttr,@SaleAttrStr,@AttrList,@AttrListStr,@Status,@Description,@CreateUserID,@ClientID)

--属性		
create table #TempTable(ID int identity(1,1),Value nvarchar(4000))
set @sql='select col='''+ replace(@SaleAttr,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)
while exists(select ID from #TempTable where ID=@AutoID)
begin
	select @AttrID=Value from #TempTable where ID=@AutoID
	if(@AttrID is not null and @AttrID<>'')
	begin
		insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime,Sort)
        values (@CategoryID,@AttrID,1,1,@CreateUserID,getdate(),@AutoID)
	end
	set @AutoID+=1
end		

truncate table #TempTable

set @AutoID=1
--规格
set @sql='select col='''+ replace(@SaleAttr,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)
while exists(select ID from #TempTable where ID=@AutoID)
begin
	select @AttrID=Value from #TempTable where ID=@AutoID
	if(@AttrID is not null and @AttrID<>'')
	begin
		insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime,Sort)
        values (@CategoryID,@AttrID,1,2,@CreateUserID,getdate(),@AutoID)
	end
	set @AutoID+=1
end


set @Err+=@@error

if(@Err>0)
begin
	set @Result=0
	set @CategoryID=''
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end