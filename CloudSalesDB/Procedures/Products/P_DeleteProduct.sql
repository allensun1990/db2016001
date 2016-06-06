Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteProduct')
BEGIN
	DROP  Procedure  P_DeleteProduct
END

GO
/***********************************************************
过程名称： P_DeleteProduct
功能描述： 删除产品
参数说明：	 
编写日期： 2016/6/4
程序作者： Allen
调试记录： exec P_DeleteProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteProduct]
@ProductID nvarchar(64),
@OperateID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据
AS

begin tran

set @Result=0

declare @Err int=0

--存在关联数据
if exists(select AutoID from StorageDetail where ProductID=@ProductID)
begin
	set @Result=10002
	rollback tran
	return
end

if exists(select AutoID from OrderDetail where ProductID=@ProductID)
begin
	set @Result=10002
	rollback tran
	return
end

if exists(select AutoID from OpportunityProduct where ProductID=@ProductID)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update Products set Status=9,UpdateTime=getdate() where ProductID=@ProductID 

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