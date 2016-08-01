Use IntFactory
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

declare @Err int,@DocType int,@OldStatus int,@OriginalID  nvarchar(64)
set @Err=0

select @DocType=DocType,@OldStatus=Status,@OriginalID=OriginalID from StorageDoc where DocID=@DocID

if(@OldStatus<>0)
begin
	rollback tran
	return
end

update StorageDoc set Status=@Status where DocID=@DocID

if(@DocType=1 and @OriginalID is not null and @OriginalID<>'')
begin
	update Orders set PurchaseStatus=0 where OrderID=@OriginalID
end

set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end