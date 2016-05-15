Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderProcessDefault')
BEGIN
	DROP  Procedure  P_UpdateOrderProcessDefault
END

GO
/***********************************************************
过程名称： P_UpdateOrderProcessDefault
功能描述： 设置默认流程
参数说明：	 
编写日期： 2016/1/29
程序作者： Allen
调试记录： exec P_UpdateOrderProcessDefault 
************************************************************/
CREATE PROCEDURE [dbo].P_UpdateOrderProcessDefault
@ProcessID nvarchar(64),
@ProcessType int,
@ClientID nvarchar(64)=''
AS

begin tran


declare @Err int=0
 
Update OrderProcess set IsDefault=0 where IsDefault=1 and ClientID=@ClientID and ProcessType=@ProcessType

Update OrderProcess set IsDefault=1 where ProcessID=@ProcessID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end