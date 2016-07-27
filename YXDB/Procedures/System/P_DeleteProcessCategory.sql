Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteProcessCategory')
BEGIN
	DROP  Procedure  P_DeleteProcessCategory
END

GO
/***********************************************************
过程名称： P_DeleteProcessCategory
功能描述： 删除订单品类
参数说明：	 
编写日期： 2016/7/27
程序作者： Allen
调试记录： exec P_DeleteProcessCategory 
************************************************************/
CREATE PROCEDURE [dbo].P_DeleteProcessCategory
@CategoryID nvarchar(64),
@UserID nvarchar(64)=''
AS

begin tran


declare @Err int=0
 
 if not exists(select AutoID from OrderProcess where CategoryID=@CategoryID and Status<>9)
 begin
	update ProcessCategory set Status=9 where CategoryID=@CategoryID

	delete from CategoryItems where CategoryID=@CategoryID
 end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end