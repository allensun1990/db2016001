Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteBrand')
BEGIN
	DROP  Procedure  P_DeleteBrand
END

GO
/***********************************************************
过程名称： P_DeleteBrand
功能描述： 删除品牌
参数说明：	 
编写日期： 2016/6/1
程序作者： Allen
调试记录： exec P_DeleteBrand 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteBrand]
@BrandID nvarchar(64),
@OperateID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据
AS

begin tran

set @Result=0

declare @Err int=0

--存在关联数据
if exists(select AutoID from Products where BrandID=@BrandID and Status<>9)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update Brand set Status=9 where BrandID=@BrandID 

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