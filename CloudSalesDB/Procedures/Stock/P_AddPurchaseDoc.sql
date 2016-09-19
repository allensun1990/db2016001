 
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddPurchaseDoc')
BEGIN
	DROP  Procedure  P_AddPurchaseDoc
END

GO
/***********************************************************
过程名称： P_AddPurchaseDoc
功能描述： 创建 采购单据和供应商订单
参数说明：	 
编写日期： 2016/08/18
程序作者： Michaux
调试记录： exec P_AddPurchaseDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddPurchaseDoc]
@ProductID nvarchar(64),
@ProductDetails nvarchar(4000),
@CMClientID nvarchar(64),
@DocID nvarchar(64),
@DocCode nvarchar(64),
@DocType int,
@SourceType int=1,
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
	@CustomerID varchar(64)='',@OwnerID varchar(64)='',@Quantity int,@NewAgentID nvarchar(64),
	@ProductDetailID varchar(64),@DepotID nvarchar(64),@NewProductID nvarchar(64),@NewProductDetailID nvarchar(64),@DRemark nvarchar(4000),
	@ProviderID varchar(64),@ProviderType int,@ProviderName nvarchar(200)

	select  @AutoID=1,@NewCode=@DocCode+convert(nvarchar(10),@AutoID),@OrderID=NEWID()
	
	select @ProviderID=ProviderID,@ProviderType=ProviderType,@ProviderName=Name 
	from Providers where ClientID=@ClientID and CMClientID=@CMClientID and Status=1
	--店铺未关注
	if(@ProviderID is null or @ProviderID='')
	begin
		rollback tran
		return
	end

	declare	@TempDetailTable table(AutoID int identity(1,1), ID varchar(64), Quantity int)

	if(@WareID='')
	begin
		select top 1 @WareID=WareID from WareHouse where Status=1 and ClientID=@ClientID
	end   

	--不存在产品
	if not exists(select AutoID from Products where ClientID=@ClientID and CMGoodsID=@ProductID)
	begin
		set @NewProductID= NewID()
		INSERT INTO [Products]([ProductID],[ProductCode],[ProductName],[GeneralName],[IsCombineProduct],[BrandID],[BigUnitID],[UnitName],[BigSmallMultiple] ,
						[CategoryID],[CategoryIDList],[SaleAttr],SaleAttrStr,[AttrList],[ValueList],[AttrValueList],AttrValueStr,[CommonPrice],[Price],[PV],[TaxRate],[Status],
						[OnlineTime],[UseType],[IsNew],[IsRecommend] ,[IsDiscount],[DiscountValue],[SaleCount],[Weight] ,[ProductImage],[EffectiveDays],
						[ShapeCode] ,[ProviderID],[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsAllow,IsAutoSend,HasDetails,WarnCount,CMGoodsID,CMGoodsCode)
			select @NewProductID,[ProductCode],[ProductName],[GeneralName],[IsCombineProduct],'','',[UnitName],1 ,
						'','','',SaleAttrStr,'','','',AttrValueStr,[CommonPrice],[Price],[PV],[TaxRate],[Status],
						getdate(),[UseType],1,0 ,1,1,0,[Weight] ,[ProductImage],[EffectiveDays],
						[ShapeCode] ,@ProviderID,[Description],@UserID,getdate() ,getdate(),[OperateIP] ,@ClientID,0,0,1,WarnCount,ProductID,ProductCode
						from [Products] where ProductID=@ProductID
		set @Err+=@@Error

		INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[BigPrice],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
			select NEWID(),@NewProductID,'','','','',[Price],[Price],1,Weight,ProductImage,'','',@UserID,getdate(),getdate(),'',@ClientID,1 
			from [Products] where ProductID=@ProductID

		set @Err+=@@Error
	end
	else
	begin
		select @NewProductID=ProductID from Products where ClientID=@ClientID and CMGoodsID=@ProductID
	end

	--处理规格产品
	set @sql='select ID='''+ replace(@ProductDetails,',',''' union all select ''')+''''
	set @sql= replace(@sql,':',''',Quantity=''') 
	insert into @TempDetailTable(ID,Quantity) exec (@sql)

	while exists(select AutoID from @TempDetailTable where AutoID=@AutoID)
	begin
		select @ProductDetailID=ID,@Quantity=Quantity from @TempDetailTable where AutoID=@AutoID
		select @DRemark=Remark from ProductDetail where ProductDetailID=@ProductDetailID
		--规格产品不存在
		if not exists(select AutoID from ProductDetail where ProductID=@NewProductID and Remark=@DRemark)
		begin
			set @NewProductDetailID=NEWID()
			INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode,BigPrice ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[Status],Remark,IsDefault,
				[Weight],ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID])
			select @NewProductDetailID,@NewProductID,DetailsCode,BigPrice,[SaleAttr],[AttrValue],[SaleAttrValue],Price,1,Remark,IsDefault,
				[Weight],ImgS,ShapeCode,[Description],@UserID,getdate(),getdate(),'',@ClientID from ProductDetail where ProductDetailID=@ProductDetailID
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
			select @DocID,@NewProductDetailID,@NewProductID,p.UnitID,p.UnitName,0,@Quantity,d.Price,d.Price*@Quantity,@WareID,@DepotID,'',0,Remark,@ClientID,p.ProductName,p.ProductCode,d.DetailsCode,d.ImgS 
			from ProductDetail d join Products p on d.ProductID=p.ProductID 
			where d.ProductDetailID=@NewProductDetailID
		
		--店铺插入销售订单
		insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,DepotID,BatchCode,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,CreateTime,CreateUserID,ProviderID,ProviderName)
			select @OrderID,@NewProductDetailID,@NewProductID,p.UnitID,p.UnitName,0,@Quantity,d.Price,d.Price*@Quantity,'','',Remark,@CMClientID,p.ProductName,p.ProductCode,d.DetailsCode,d.ImgS,GETDATE(),@UserID,'','' 
			from ProductDetail d join Products p on d.ProductID=p.ProductID 
			where d.ProductDetailID=@NewProductDetailID

		set @AutoID=@AutoID+1
	end

	--采购单
	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,ProviderID,CreateUserID,CreateTime,OperateIP,ClientID,ProviderName,SourceType)
	values(@DocID,@NewCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,@ProviderID,@UserID,GETDATE(),'',@ClientID,@ProviderName,2) 
	set @Err+=@@Error

	--销售订单
	select top 1 @CustomerID=CustomerID,@OwnerID=OwnerID,@NewAgentID=AgentID from Customer where ChildClientID=@ClientID and ClientID=@CMClientID
	if(@NewAgentID is null or @NewAgentID='')
	begin
		select @NewAgentID=AgentID from Clients where ClientID=@CMClientID
	end
	insert into Orders(OrderID,OrderCode,TypeID,Status,SendStatus,OutStatus,ReturnStatus,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CreateUserID,CreateTime,OperateIP,AgentID,ClientID,SourceType,CustomerID,OwnerID)
	values(@OrderID,@NewCode,'',1,0,0,0,@TotalMoney,@CityCode,@Address,@PersonName,@MobilePhone,@Remark,@UserID,GETDATE(),'',@NewAgentID,@CMClientID,2,@CustomerID,@OwnerID)
	set @Err+=@@Error
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end