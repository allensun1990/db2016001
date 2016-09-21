 
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddIntfactoryPurchaseDoc')
BEGIN
	DROP  Procedure  P_AddIntfactoryPurchaseDoc
END

GO
/***********************************************************
过程名称： P_AddIntfactoryPurchaseDoc
功能描述： 创建智能工厂采购订单
参数说明：	 
编写日期： 2016/09/20
程序作者： Allen
调试记录： 
		exec P_AddIntfactoryPurchaseDoc 
		@GoodsID = N'DF399AAE-782E-4F72-AD97-E55E3204CA96',
		@GoodsCode = N'NO1232323',
		@GoodsName = N'最新款',
		@Price = 66,
		@SaleAttrStr = N'颜色,尺码',
		@ProductDetails = N'白色,L|颜色:白色,尺码:L|10|660|[颜色：白色][尺码：L]&红色,M|颜色:红色,尺码:M|20|1320|[颜色：红色][尺码：M]&红色,L|颜色:红色,尺码:L|30|1980|[颜色：红色][尺码：L]',
		@CMClientID = N'eda082bc-b848-4de8-8776-70235424fc06',
		@DocID = N'E08E44E3-7E4C-4FAC-80D7-BF6969155025',
		@DocCode = N'20160920161932190',
		@DocType = 2,
		@SourceType = 0,
		@TotalMoney = 3300,
		@PersonName = N'剑客',
		@MobilePhone = N'+8613120611062',
		@CityCode = N'330411',
		@Address = N'长宁区中山西路1279弄6号6楼',
		@UserID = N'f2124924-76cc-4bec-bac3-80ff56fbc753',
		@AgentID = N'1FCDECFF-B600-4A8B-A3CF-E97BE232952C',
		@ClientID = N'5e4e595e-ca34-4bb4-be6b-6a437f72159c'
************************************************************/
CREATE PROCEDURE [dbo].[P_AddIntfactoryPurchaseDoc]
@GoodsID nvarchar(64),
@GoodsCode nvarchar(2000),
@GoodsName nvarchar(2000),
@Price decimal(18,4),
@SaleAttrStr nvarchar(4000)='',
@ProductImage nvarchar(4000)='',
@ProductDetails nvarchar(4000),
@CMClientID nvarchar(64),
@DocID nvarchar(64),
@DocCode nvarchar(64),
@DocType int,
@SourceType int=0,
@TotalMoney decimal(18,2)=0,
@PersonName varchar(50)='',
@MobilePhone varchar(50)='',
@CityCode nvarchar(10)='',
@Address nvarchar(500)='',
@Remark nvarchar(500)='',
@WareID nvarchar(64)='', 
@UserID nvarchar(64), 
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS

if(@CMClientID=@ClientID)
begin
	return
end 

begin tran

	declare @Err int=0,@AutoID int,@sql varchar(4000),@NewCode nvarchar(64),@OrderID nvarchar(64),@OrderCode nvarchar(64),
	@CustomerID varchar(64)='',@OwnerID varchar(64)='',@NewAgentID nvarchar(64),@ProductID nvarchar(64),
	@ProductDetailID varchar(64),@DepotID nvarchar(64),@NewProductID nvarchar(64),@NewProductDetailID nvarchar(64),
	@ProviderID varchar(64),@ProviderType int,@ProviderName nvarchar(200)

	select  @AutoID=1,@NewCode=@DocCode+Convert(nvarchar(10),@AutoID),@OrderID=NEWID()

	select @ProviderID=ProviderID,@ProviderType=ProviderType,@ProviderName=Name 
	from Providers where ClientID=@ClientID and CMClientID=@CMClientID and Status=1
	--店铺未关注
	if(@ProviderID is null or @ProviderID='')
	begin
		rollback tran
		return
	end
	--供应商客户不存在产品
	if not exists(select AutoID from Products where ClientID=@CMClientID and CMGoodsID=@GoodsID)
	begin
		declare @TempProviderID nvarchar(64),@TempClientID nvarchar(64)
		select @TempClientID=CMClientID from Clients where ClientID=@CMClientID
		select @TempProviderID=ProviderID from Providers where ClientID=@CMClientID and CMClientID=@TempClientID 
		set @ProductID= NewID()
		INSERT INTO [Products](SourceType,[ProductID],[ProductCode],[ProductName],[GeneralName],[IsCombineProduct],[BrandID],[BigUnitID],[UnitName],[BigSmallMultiple] ,
						[CategoryID],[CategoryIDList],[SaleAttr],SaleAttrStr,[AttrList],[ValueList],[AttrValueList],AttrValueStr,[CommonPrice],[Price],[PV],[TaxRate],[Status],
						[OnlineTime],[UseType],[IsNew],[IsRecommend] ,[IsDiscount],[DiscountValue],[SaleCount],[Weight] ,[ProductImage],[EffectiveDays],
						[ShapeCode] ,[ProviderID],[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsAllow,IsAutoSend,HasDetails,WarnCount,CMGoodsID,CMGoodsCode)
			values(1,@ProductID,@GoodsCode,@GoodsName,'',0,'','','件',1 ,
						'','','',@SaleAttrStr,'','','','',@Price,@Price,0,0,1,
						getdate(),0,1,0 ,1,1,0,0 ,@ProductImage,0,
						0 ,@TempProviderID,'','',getdate() ,getdate(),'' ,@CMClientID,0,0,1,0,@GoodsID,@GoodsCode)
		set @Err+=@@Error

		INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[BigPrice],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
			values( NEWID(),@ProductID,'','','','',@Price,@Price,1,0,@ProductImage,'','','',getdate(),getdate(),'',@CMClientID,1 )

		set @Err+=@@Error
	end
	else
	begin
		select @ProductID=ProductID from Products where ClientID=@CMClientID and CMGoodsID=@GoodsID
	end

	if(@WareID='')
	begin
		select top 1 @WareID=WareID from WareHouse where Status=1 and ClientID=@ClientID
	end   

	select @SourceType=SourceType from [Products] where ProductID=@ProductID

	--下单客户不存在产品
	if not exists(select AutoID from Products where ClientID=@ClientID and CMGoodsID=@ProductID)
	begin
		set @NewProductID= NewID()
		INSERT INTO [Products](SourceType,[ProductID],[ProductCode],[ProductName],[GeneralName],[IsCombineProduct],[BrandID],[BigUnitID],[UnitName],[BigSmallMultiple] ,
						[CategoryID],[CategoryIDList],[SaleAttr],SaleAttrStr,[AttrList],[ValueList],[AttrValueList],AttrValueStr,[CommonPrice],[Price],[PV],[TaxRate],[Status],
						[OnlineTime],[UseType],[IsNew],[IsRecommend] ,[IsDiscount],[DiscountValue],[SaleCount],[Weight] ,[ProductImage],[EffectiveDays],
						[ShapeCode] ,[ProviderID],[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsAllow,IsAutoSend,HasDetails,WarnCount,CMGoodsID,CMGoodsCode)
			values(2,@NewProductID,@GoodsCode,@GoodsName,'',0,'','','件',1 ,
						'','','',@SaleAttrStr,'','','','',@Price,@Price,0,0,1,
						getdate(),0,1,0 ,1,1,0,0 ,@ProductImage,0,
						0 ,@ProviderID,'',@UserID,getdate() ,getdate(),'' ,@ClientID,0,0,1,0,@ProductID,'')
		set @Err+=@@Error

		INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[BigPrice],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
			values( NEWID(),@NewProductID,'','','','',@Price,@Price,1,0,@ProductImage,'','',@UserID,getdate(),getdate(),'',@ClientID,1 )

		set @Err+=@@Error
	end
	else
	begin
		select @NewProductID=ProductID from Products where ClientID=@ClientID and CMGoodsID=@ProductID
	end

	declare	@TempDetailTable table(AutoID int identity(1,1), Value nvarchar(4000))
	create table #TempDetailInfo(AutoID int identity(1,1), Value nvarchar(4000))
	declare @Value nvarchar(4000),@ValueStr nvarchar(4000),@AttrValueStr nvarchar(4000),@Quantity int,@DPrice decimal(18,4),@DRemark nvarchar(4000)

	--处理规格产品
	set @sql='select '''+ replace(@ProductDetails,'&',''' union all select ''')+''''
	insert into @TempDetailTable(Value) exec (@sql)

	while exists(select AutoID from @TempDetailTable where AutoID=@AutoID)
	begin
		select @Value=Value from @TempDetailTable where AutoID=@AutoID
		set @sql='select '''+ replace(@Value,'|',''' union all select ''')+''''

		truncate table #TempDetailInfo
		insert into #TempDetailInfo(Value) exec (@sql)

		select @ValueStr=Value from #TempDetailInfo where AutoID=1 
		select @AttrValueStr=Value from #TempDetailInfo where AutoID=2
		select @Quantity=convert(int, Value) from #TempDetailInfo where AutoID=3
		select @DPrice=convert(decimal(18,4), Value) from #TempDetailInfo where AutoID=4
		select @DRemark=Value from #TempDetailInfo where AutoID=5

		--供应商不存在规格产品
		if not exists(select AutoID from ProductDetail where ProductID=@ProductID and Remark=@DRemark)
		begin
			set @ProductDetailID=NEWID()
			INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode,BigPrice ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[Status],Remark,IsDefault,
				[Weight],ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID])
			values (@ProductDetailID,@ProductID,'',@DPrice,@SaleAttrStr,@ValueStr,@AttrValueStr,@DPrice,1,@DRemark,0,
				0,@ProductImage,'','','',getdate(),getdate(),'',@CMClientID)
		end
		else
		begin
			select @ProductDetailID=ProductDetailID from ProductDetail where ProductID=@ProductID and Remark=@DRemark
		end


		--下单客户规格产品不存在
		if not exists(select AutoID from ProductDetail where ProductID=@NewProductID and Remark=@DRemark)
		begin
			set @NewProductDetailID=NEWID()
			INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode,BigPrice ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[Status],Remark,IsDefault,
				[Weight],ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID])
			values (@NewProductDetailID,@NewProductID,'',@DPrice,@SaleAttrStr,@ValueStr,@AttrValueStr,@DPrice,1,@DRemark,0,
				0,@ProductImage,'','','',getdate(),getdate(),'',@ClientID)
		end
		else
		begin
			select @NewProductDetailID=ProductDetailID from ProductDetail where ProductID=@NewProductID and Remark=@DRemark
		end

		--处理货位
		if exists(select AutoID from ProductStock where ProductDetailID=@NewProductDetailID and WareID=@WareID)
		begin
			select top 1 @DepotID= DepotID from ProductStock where ProductDetailID=@NewProductDetailID and WareID=@WareID
		end
		else
		begin
			select top 1 @DepotID = DepotID from DepotSeat where WareID=@WareID and Status=1
		end

		--插入采购单
		insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage)
			values( @DocID,@NewProductDetailID,@NewProductID,'','件',0,@Quantity,@DPrice,@DPrice*@Quantity,@WareID,@DepotID,'',0,@DRemark,@ClientID,@GoodsName,@GoodsCode,'',@ProductImage) 

		
		--店铺插入销售订单
		insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,DepotID,BatchCode,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,CreateTime,CreateUserID,ProviderID,ProviderName)
			values( @OrderID,@ProductDetailID,@ProductID,'','件',0,@Quantity,@DPrice,@DPrice*@Quantity,'','',@DRemark,@CMClientID,@GoodsName,@GoodsCode,'',@ProductImage,GETDATE(),'','','') 
			

		set @AutoID=@AutoID+1
	end

	--采购单
	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,ProviderID,CreateUserID,CreateTime,OperateIP,ClientID,ProviderName,SourceType)
	values(@DocID,@NewCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,@ProviderID,@UserID,GETDATE(),'',@ClientID,@ProviderName,1) 
	set @Err+=@@Error

	--销售订单
	select top 1 @CustomerID=CustomerID,@OwnerID=OwnerID,@NewAgentID=AgentID from Customer where ChildClientID=@ClientID and ClientID=@CMClientID
	if(@NewAgentID is null or @NewAgentID='')
	begin
		select @NewAgentID=AgentID from Clients where ClientID=@CMClientID
	end

	update Customer set OrderCount=OrderCount+1 where CustomerID=@CustomerID
	 
	insert into Orders(OrderID,OrderCode,TypeID,Status,SendStatus,OutStatus,ReturnStatus,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CreateUserID,CreateTime,OperateIP,AgentID,ClientID,SourceType,CustomerID,OwnerID,OriginalID,OriginalCode)
	values(@OrderID,@NewCode,'',1,0,0,0,@TotalMoney,@CityCode,@Address,@PersonName,@MobilePhone,@Remark,'',GETDATE(),'',@NewAgentID,@CMClientID,2,@CustomerID,@OwnerID,@DocID,@NewCode)
	set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end