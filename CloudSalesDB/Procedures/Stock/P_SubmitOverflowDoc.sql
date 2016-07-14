Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_SubmitOverflowDoc')
BEGIN
	DROP  Procedure  P_SubmitOverflowDoc
END

GO
/***********************************************************
过程名称： P_SubmitOverflowDoc
功能描述： 创建报溢单据
参数说明：	 
编写日期： 2015/12/12
程序作者： Allen
调试记录： exec P_SubmitOverflowDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_SubmitOverflowDoc]
@DocID nvarchar(64),
@DocCode nvarchar(20),
@DocType int,
@AutoIDs nvarchar(4000),
@CityCode nvarchar(10)='',
@Address nvarchar(500)='',
@Remark nvarchar(500)='',
@WareID nvarchar(64)='',
@UserID nvarchar(64),
@OperateIP nvarchar(50),
@ClientID nvarchar(64)
AS

begin tran

declare @Err int=0,@TotalMoney decimal(18,2)=0,@sql nvarchar(4000)

create table #TempTable(ID int)
set @sql='select col='''+ replace(@AutoIDs,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)

if exists(select AutoID from ShoppingCart where UserID=@UserID and [GUID]=@UserID and OrderType=@DocType and AutoID in (select ID from #TempTable))
begin
	
	declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@BatchCode nvarchar(50),@DepotID nvarchar(64),
	@DRemark nvarchar(4000),@Price decimal(18,4),@UnitID nvarchar(64)

	select identity(int,1,1) as AutoID,ProductDetailID,ProductID,UnitID ,UnitName,Quantity,Price,BatchCode,Remark,ProductName,ProductCode,DetailsCode,ProductImage  into #TempProducts 
	from ShoppingCart 
	where UserID=@UserID and [GUID]=@UserID and OrderType=@DocType and AutoID in (select ID from #TempTable)

	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
		
		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@BatchCode=BatchCode,@DRemark=Remark,@Price=Price,@UnitID=UnitID 
		from #TempProducts where AutoID=@AutoID


		if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID)
		begin
			select top 1 @DepotID=DepotID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID order by BatchCode desc
		end
		else
		begin
			select top 1 @DepotID = DepotID from DepotSeat where WareID=@WareID and Status=1
		end


		insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage)
		select @DocID,ProductDetailID,ProductID,UnitID,UnitName,0,Quantity,Price,Quantity*Price,@WareID,@DepotID,BatchCode,0,Remark,@ClientID ,ProductName,ProductCode,DetailsCode,ProductImage 
		from #TempProducts where AutoID=@AutoID

		set @Err+=@@Error

		set @AutoID=@AutoID+1
	end


	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID)
	values(@DocID,@DocCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,@UserID,GETDATE(),@OperateIP,@ClientID)

	delete from ShoppingCart  where UserID=@UserID and [GUID]=@UserID and OrderType=@DocType and AutoID in (select ID from #TempTable)
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