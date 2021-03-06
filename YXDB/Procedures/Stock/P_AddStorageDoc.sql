﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddStorageDoc')
BEGIN
	DROP  Procedure  P_AddStorageDoc
END

GO
/***********************************************************
过程名称： P_AddStorageDoc
功能描述： 创建单据
参数说明：	 
编写日期： 2015/9/18
程序作者： Allen
调试记录： exec P_AddStorageDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddStorageDoc]
@DocID nvarchar(64),
@DocCode nvarchar(20),
@DocType int,
@TotalMoney decimal(18,2)=0,
@CityCode nvarchar(10)='',
@Address nvarchar(500)='',
@Remark nvarchar(500)='',
@WareID nvarchar(64)='',
@UserID nvarchar(64),
@OperateIP nvarchar(50),
@ClientID nvarchar(64)
AS

begin tran

declare @Err int=0

if exists(select AutoID from ShoppingCart where  [GUID]=@UserID and UserID=@UserID and OrderType=@DocType)
begin
	
	declare @AutoID int=1,@DepotID nvarchar(64),@ProductDetailID nvarchar(64)


	select identity(int,1,1) as AutoID,ProductDetailID,ProductID, UnitID,Quantity,Price,DepotID,Remark,s.ProviderID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS into #TempProducts 
	from ShoppingCart s where [GUID]=@UserID and OrderType=@DocType and UserID=@UserID

	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
		
		select @ProductDetailID=ProductDetailID,@DepotID=DepotID from #TempProducts where AutoID=@AutoID

		if(@DepotID is null or @DepotID='')
		begin
			if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID)
			begin
				select top 1 @DepotID= DepotID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID 
			end
			else
			begin
				select top 1 @DepotID = DepotID from DepotSeat where WareID=@WareID and Status=1 order by Sort 
			end
		end

		insert into StorageDetail(DocID,ProductDetailID,ProductID,ProviderID,UnitID,Quantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS)
		select @DocID,ProductDetailID,ProductID,ProviderID,UnitID,Quantity,Price,Price*Quantity,@WareID,@DepotID,0,Remark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS
		from #TempProducts where AutoID=@AutoID

		set @Err+=@@Error

		set @AutoID=@AutoID+1
	end


	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,ProviderID,CreateUserID,CreateTime,OperateIP,ClientID)
	values(@DocID,@DocCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,'',@UserID,GETDATE(),@OperateIP,@ClientID)


	delete from ShoppingCart  where [GUID]=@UserID and OrderType=@DocType and UserID=@UserID 
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