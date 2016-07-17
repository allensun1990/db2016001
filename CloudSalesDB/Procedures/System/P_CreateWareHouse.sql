Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateWareHouse')
BEGIN
	DROP  Procedure  P_CreateWareHouse
END

GO
/***********************************************************
过程名称： P_CreateWareHouse
功能描述： 添加仓库
参数说明：	 
编写日期： 2015/11/11
程序作者： Allen
调试记录： exec P_CreateWareHouse 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateWareHouse]
@WareID nvarchar(64),
@WareCode nvarchar(100),
@Name nvarchar(100),
@ShortName nvarchar(100),
@CityCode nvarchar(10),
@Status int,
@DepotID nvarchar(64)='',
@DepotCode nvarchar(50),
@DepotName nvarchar(50)='',
@Description nvarchar(4000),
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran


declare @Err int=0
 
insert into WareHouse(WareID,WareCode,Name,ShortName,CityCode,Status,Description,CreateUserID,ClientID) 
              values(@WareID,@WareCode,@Name,@ShortName,@CityCode,@Status,@Description,@CreateUserID,@ClientID)

insert into DepotSeat(DepotID,DepotCode,WareID,Name,Status,CreateUserID,ClientID)
values(@DepotID,@DepotCode,@WareID,@DepotName,1,@CreateUserID,@ClientID)

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end