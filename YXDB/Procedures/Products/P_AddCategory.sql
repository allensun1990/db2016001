Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddCategory')
BEGIN
	DROP  Procedure  P_AddCategory
END

GO
/***********************************************************
过程名称： P_AddCategory
功能描述： 添加产品分类
参数说明：	 
编写日期： 2015/5/25
程序作者： Allen
调试记录： exec P_AddCategory 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddCategory]
@CategoryCode nvarchar(200),
@CategoryName nvarchar(200),
@CategoryType int,
@PID nvarchar(64),
@AttrList nvarchar(4000),
@SaleAttr nvarchar(4000),
@Status int,
@Description nvarchar(4000),
@CreateUserID nvarchar(64),
@CategoryID nvarchar(64) output 
AS

begin tran

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

insert into Category(CategoryID,CategoryCode,CategoryName,CategoryType,PID,PIDList,Layers,SaleAttr,AttrList,Status,Description,CreateUserID)
				values(@CategoryID,@CategoryCode,@CategoryName,@CategoryType,@PID,@PIDList,@Layers,@SaleAttr,@AttrList,@Status,@Description,@CreateUserID)

set @Err+=@@error

if(@Err>0)
begin
	set @CategoryID=''
	rollback tran
end 
else
begin
	commit tran
end