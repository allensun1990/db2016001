Use [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteProductAttr')
BEGIN
	DROP  Procedure  P_DeleteProductAttr
END

GO
/***********************************************************
过程名称： P_DeleteProductAttr
功能描述： 删除属性
参数说明：	 
编写日期： 2016/6/1
程序作者： Allen
调试记录： exec P_DeleteProductAttr 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteProductAttr]
@AttrID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据
AS

begin tran

set @Result=0

declare @Err int=0

--存在关联数据
if exists(select c.AutoID from Category c join CategoryAttr a on c.CategoryID=a.CategoryID where c.Status<>9 and a.AttrID=@AttrID and a.Status<>9)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update ProductAttr set Status=9,UpdateTime=getdate()  where [AttrID]=@AttrID 

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end