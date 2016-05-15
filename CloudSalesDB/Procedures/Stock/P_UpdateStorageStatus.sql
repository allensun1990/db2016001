Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateStorageStatus')
BEGIN
	DROP  Procedure  P_UpdateStorageStatus
END

GO
/***********************************************************
过程名称： P_UpdateStorageStatus
功能描述： 编辑单据状态
参数说明：	 
编写日期： 2015/10/12
程序作者： Allen
调试记录： exec P_UpdateStorageStatus 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateStorageStatus]
@DocID nvarchar(64),
@Status int,
@Remark nvarchar(500)='',
@UserID nvarchar(64),
@OperateIP nvarchar(64)='',
@ClientID nvarchar(64)
AS

begin tran

declare @Err int
set @Err=0

if exists(select AutoID from StorageDoc where DocID=@DocID and Status<>0)
begin
	rollback tran
	return
end

update StorageDoc set Status=@Status where DocID=@DocID

--记录审核日志
insert into StorageDocAction(DocID,Remark,CreateTime,CreateUserID,OperateIP)
					values( @DocID,@Remark,getdate(),@UserID,@OperateIP)


set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end