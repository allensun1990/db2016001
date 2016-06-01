Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteUnit')
BEGIN
	DROP  Procedure  P_DeleteUnit
END

GO
/***********************************************************
过程名称： P_DeleteUnit
功能描述： 删除单位
参数说明：	 
编写日期： 2016/6/1
程序作者： Allen
调试记录： exec P_DeleteUnit 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteUnit]
@UnitID nvarchar(64),
@OperateID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据
AS

begin tran

set @Result=0

declare @Err int=0

--存在关联数据
if exists(select AutoID from Products where UnitID=@UnitID and Status<>9)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update ProductUnit set Status=9 where UnitID=@UnitID 

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