Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_SubmitDamagedDoc')
BEGIN
	DROP  Procedure  P_SubmitDamagedDoc
END

GO
/***********************************************************
过程名称： P_SubmitDamagedDoc
功能描述： 创建报损单据
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录： exec P_SubmitDamagedDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_SubmitDamagedDoc]
@DocID nvarchar(64),
@DocCode nvarchar(20),
@DocType int,
@TotalMoney decimal(18,2)=0,
@CityCode nvarchar(10)='',
@Address nvarchar(500)='',
@Remark nvarchar(500)='',
@AutoIDs nvarchar(4000)='',
@UserID nvarchar(64),
@OperateIP nvarchar(50),
@ClientID nvarchar(64)
AS

begin tran

declare @Err int=0,@ProviderAutoID int=1,@WareID nvarchar(64)='',@NewCode nvarchar(50),@sql nvarchar(4000)

create table #TempTable(ID int)
set @sql='select col='''+ replace(@AutoIDs,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)

if exists(select AutoID from ShoppingCart where AutoID in (select ID from #TempTable))
begin
	
	declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@ProductImage nvarchar(4000),@ImgS nvarchar(4000)

	select identity(int,1,1) as AutoID,ProductDetailID,ProductID,UnitID,UnitName,Quantity,Price,WareID,DepotID,BatchCode,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,ProviderName into #TempShoppingCart
	from ShoppingCart where UserID=@UserID and [GUID]=@UserID and OrderType=@DocType and AutoID in (select ID from #TempTable)

	select identity(int,1,1) as AutoID,WareID into #TempProvider from #TempShoppingCart group by  WareID

	--循环代理商
	while exists(select AutoID from #TempProvider where AutoID=@ProviderAutoID)
	begin
		select @WareID=WareID,@AutoID=1,@DocID=NEWID(),@NewCode=@DocCode+convert(nvarchar(10),@ProviderAutoID) from #TempProvider where AutoID=@ProviderAutoID
		--取得代理商产品
		select identity(int,1,1) as AutoID,ProductDetailID,ProductID,UnitID,UnitName,Quantity,Price,WareID,DepotID,BatchCode,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,ProviderName into #TempProducts 
		from #TempShoppingCart where WareID=@WareID

		while exists(select AutoID from #TempProducts where AutoID=@AutoID)
		begin
		
			select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@ProductImage=ProductImage,@ImgS=ImgS from #TempProducts where AutoID=@AutoID
			if(@ImgS is null or @ImgS='')
			begin
				set @ImgS=@ProductImage
			end

			insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage)
			select @DocID,@ProductDetailID,@ProductID,UnitID,UnitName,0,Quantity,Price,Price*Quantity,@WareID,DepotID,BatchCode,0,Remark,@ClientID,ProductName,ProductCode,DetailsCode,@ImgS from #TempProducts where AutoID=@AutoID

			set @Err+=@@Error

			set @AutoID=@AutoID+1
		end

		select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

		insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,ProviderID,CreateUserID,CreateTime,OperateIP,ClientID,ProviderName)
		values(@DocID,@NewCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,'',@UserID,GETDATE(),@OperateIP,@ClientID,'')

		Drop table #TempProducts

		set @ProviderAutoID=@ProviderAutoID+1
	end

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