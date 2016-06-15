Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateDepotSeat')
BEGIN
	DROP  Procedure  P_CreateDepotSeat
END

GO
/***********************************************************
过程名称： P_CreateDepotSeat
功能描述： 添加货位
参数说明：	 
编写日期： 2015/11/11
程序作者： Allen
调试记录： exec P_CreateDepotSeat 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateDepotSeat]
@DepotID nvarchar(64),
@WareID nvarchar(64),
@Name nvarchar(100),
@Status int,
@DepotCode nvarchar(50),
@Description nvarchar(4000),
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran


declare @Err int=0,@Sort int
 
select @Sort=max(Sort) from DepotSeat where WareID=@WareID

insert into DepotSeat(DepotID,DepotCode,WareID,Name,Status,Sort,Description,CreateUserID,ClientID) 
 values(@DepotID,@DepotCode,@WareID,@Name,@Status,@Sort+1,@Description,@CreateUserID,@ClientID)

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end