Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateDepotSeatSort')
BEGIN
	DROP  Procedure  P_UpdateDepotSeatSort
END

GO
/***********************************************************
过程名称： P_UpdateDepotSeatSort
功能描述： 货位排序
参数说明：	 
编写日期： 2016/5/21
程序作者： Allen
调试记录： exec P_UpdateDepotSeatSort 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateDepotSeatSort]
@DepotID nvarchar(64),
@WareID nvarchar(64),
@Type int=0
AS

begin tran


declare @Err int=0,@Sort int,@NewSort int,@NewID nvarchar(64)

select @Sort=Sort from DepotSeat where DepotID=@DepotID

if(@Type=0 and exists(select AutoID from DepotSeat where Sort<=@Sort and WareID=@WareID and DepotID<>@DepotID and Status<>9))
begin
	select top 1 @NewSort=Sort,@NewID=DepotID from DepotSeat where Sort<=@Sort and WareID=@WareID and DepotID<>@DepotID and Status<>9 order by Sort desc

	Update DepotSeat set Sort=@NewSort where DepotID=@DepotID 

	Update DepotSeat set Sort=@Sort where DepotID=@NewID 
end
else if(@Type=1 and exists(select AutoID from DepotSeat where Sort>=@Sort and WareID=@WareID and DepotID<>@DepotID and Status<>9))
begin
	select top 1 @NewSort=Sort,@NewID=DepotID from DepotSeat where Sort>=@Sort and WareID=@WareID and DepotID<>@DepotID and Status<>9 order by Sort

	Update DepotSeat set Sort=@NewSort where DepotID=@DepotID 

	Update DepotSeat set Sort=@Sort where DepotID=@NewID 
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