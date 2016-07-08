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

declare @Err int, @OldAttr nvarchar(4000),@OldSales nvarchar(4000)
set @Err=0

select @OldAttr=AttrList,@OldSales=SaleAttr from Category where CategoryID=@CategoryID

Update Category set CategoryName=@CategoryName,CategoryCode=@CategoryCode,Status=@Status,AttrList=@AttrList,SaleAttr=@SaleAttr,Description=@Description,UpdateTime=getdate() 
where CategoryID=@CategoryID

set @Err+=@@error

if(@AttrList<>@OldAttr)
begin
	Update CategoryAttr set Status=9,UpdateTime=getdate() where CategoryID=@CategoryID and Type=1 -- and CHARINDEX(AttrID,@AttrList)=0

	insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime)
	select @CategoryID,AttrID,1,1,@UserID,getdate() from ProductAttr 
	where ClientID=ClientID and Status<>9 and CHARINDEX(AttrID,@AttrList)>0
end

if(@SaleAttr<>@OldSales)
begin
	Update CategoryAttr set Status=9,UpdateTime=getdate() where CategoryID=@CategoryID and Type=2 --and CHARINDEX(AttrID,@SaleAttr)=0

	insert into CategoryAttr(CategoryID,AttrID,Status,Type,CreateUserID,CreateTime)
	select @CategoryID,AttrID,1,2,@UserID,getdate() from ProductAttr 
	where ClientID=ClientID and Status<>9 and CHARINDEX(AttrID,@SaleAttr)>0

	if(@SaleAttr is null or @SaleAttr='')
	begin
		update Products set HasDetails=0 where @CategoryID=CategoryID
	end
	else
	begin
		update Products set HasDetails=1 where @CategoryID=CategoryID
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