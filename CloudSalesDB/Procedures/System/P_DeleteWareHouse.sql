Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteWareHouse')
BEGIN
	DROP  Procedure  P_DeleteWareHouse
END

GO
/***********************************************************
过程名称： P_DeleteWareHouse
功能描述： 删除仓库
参数说明：	 
编写日期： 2016/7/5
程序作者： Allen
调试记录： exec P_DeleteWareHouse 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteWareHouse]
@WareID nvarchar(64),
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功，2 存在业务
AS

begin tran

set @Result=0

declare @Err int=0

--仓库存在单据
if exists(select AutoID from StorageDoc where ClientID=@ClientID and WareID=@WareID and Status<>9)
begin
	set @Result=2
	rollback tran
	return
end

set @Err+=@@error

Update WareHouse set Status=9 where WareID=@WareID

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