Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteAttrValue')
BEGIN
	DROP  Procedure  P_DeleteAttrValue
END

GO
/***********************************************************
过程名称： P_DeleteAttrValue
功能描述： 删除属性值
参数说明：	 
编写日期： 2016/6/1
程序作者： Allen
调试记录： exec P_DeleteAttrValue 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteAttrValue]
@ValueID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据
AS

begin tran

set @Result=0

declare @Err int=0

--存在关联数据
if exists(select AutoID from Products where ClientID=@ClientID and Status<>9 and ValueList like '%'+@ValueID+'%')
begin
	set @Result=10002
	rollback tran
	return
end

if exists(select AutoID from ProductDetail where ClientID=@ClientID and Status<>9 and AttrValue like '%'+@ValueID+'%')
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update AttrValue set Status=9,UpdateTime=getdate()  where [ValueID]=@ValueID

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