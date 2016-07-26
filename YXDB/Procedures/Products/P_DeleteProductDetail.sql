Use [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteProductDetail')
BEGIN
	DROP  Procedure  P_DeleteProductDetail
END

GO
/***********************************************************
过程名称： P_DeleteProductDetail
功能描述： 删除子产品
参数说明：	 
编写日期： 2016/7/26
程序作者： Allen
调试记录： exec P_DeleteProductDetail 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteProductDetail]
@ProductDetailID nvarchar(64),
@OperateID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据
AS

begin tran

set @Result=0

declare @Err int=0

--存在关联数据
if exists(select AutoID from StorageDetail where ProductDetailID=@ProductDetailID)
begin
	set @Result=10002
	rollback tran
	return
end

if exists(select AutoID from OrderDetail where ProductDetailID=@ProductDetailID)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

declare @ProductID nvarchar(64)

Update ProductDetail set Status=9,UpdateTime=getdate() where ProductDetailID=@ProductDetailID 

select @ProductID=ProductID from ProductDetail where ProductDetailID=@ProductDetailID 

if not exists(select AutoID from ProductDetail where ProductID=@ProductID and Status<>9 and IsDefault=0)
begin
	Update Products set HasDetails=0 where ProductID=@ProductID 
end

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