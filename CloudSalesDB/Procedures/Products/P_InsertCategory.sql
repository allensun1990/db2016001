﻿Use [CloudSales1.0_dev]
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
@AttrList nvarchar(4000),
@SaleAttr nvarchar(4000),
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

declare @Err int,@PIDList nvarchar(max),@Layers int=0 
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

insert into Category(CategoryID,CategoryCode,CategoryName,PID,PIDList,Layers,SaleAttr,AttrList,Status,Description,CreateUserID,ClientID)
				values(@CategoryID,@CategoryCode,@CategoryName,@PID,@PIDList,@Layers,@SaleAttr,@AttrList,@Status,@Description,@CreateUserID,@ClientID)

insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime)
select @CategoryID,AttrID,1,1,@CreateUserID,getdate() from ProductAttr where ClientID=ClientID and Status<>9 and @AttrList like '%'+AttrID+'%'

insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime)
select @CategoryID,AttrID,1,2,@CreateUserID,getdate() from ProductAttr where ClientID=ClientID and Status<>9 and @SaleAttr like '%'+AttrID+'%'

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