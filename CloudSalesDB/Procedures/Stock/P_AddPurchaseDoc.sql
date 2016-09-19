 
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
@ProviderID nvarchar(64),
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

begin tran
	declare @Err int=0,@NewCode nvarchar(50),@ProviderName nvarchar(200),@OrderID nvarchar(64),@OrderCode nvarchar(64),@prociderType int,@CustomerID varchar(64),@OwnerID varchar(64),
	@ProductDetailID varchar(64),@DepotID nvarchar(64),@AutoID int,@sql varchar(4000) ,@PProviderID varchar(50),@temppoductid varchar(64)
	select  @AutoID=1,@NewCode=@DocCode+convert(nvarchar(10),@AutoID),@OrderID=NEWID(),@CustomerID='',@OwnerID='',@PProviderID=''
	
	declare	@TempTable table(ID varchar(64),Quantity int)
	
	

	if(@WareID='')
	begin
		select top 1 @WareID=WareID from WareHouse where Status=1 and ClientID=@ClientID
	end   

	if(@ProviderID=@ClientID)
	begin
		set @temppoductid=@ProductID
		set @sql='select ID='''+ replace(@ProductDetails,',',''' union all select ''')+''''
		set @sql= replace(@sql,':',''',Quantity=''') 
		insert into @TempTable(ID,Quantity) exec (@sql)
		/*自家店铺*/
		select @ProviderName=Name,@PProviderID=CMClientID,@prociderType=ProviderType  from Providers where ClientID=@ClientID and ProviderType=1
	end 
	else
	begin 
		declare	@TempDetailTable table(ID varchar(64),Quantity int,status int default(0)) 
		set @sql='select ID='''+ replace(@ProductDetails,',',''' union all select ''')+''''
		set @sql= replace(@sql,':',''',Quantity=''') 
		insert into @TempDetailTable(ID,Quantity) exec (@sql)

		/*关注店铺需验证产品是否存在*/
		select @ProviderName=Name,@PProviderID=CMClientID,@prociderType=ProviderType  from Providers where ProviderID=@ProviderID and ClientID=@ClientID
		select @temppoductid=productid  from products where CMGoodsID=@ProductID and ClientID=@ClientID
		--如果产品为空插入
		if(isnull(@temppoductid,'')='') 
		begin
			set @temppoductid=newid()
			insert into products(productid,productcode,productname,unitname,CommonPrice,price,pv,taxrate,isnew,[weight],ProductImage,EffectiveDays,WarnCount,ProviderID,[Description],CreateUserID,ClientID,CMGoodsID,CMGoodsCode)
			select @temppoductid,productcode,productname,unitname,CommonPrice,price,pv,taxrate,1,[weight],ProductImage,EffectiveDays,WarnCount,@PProviderID,[Description],@UserID,@ClientID,productid,productcode from  products where productid=@ProductID 
			set @Err+=@@Error

			INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[BigPrice],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
				select NEWID(),@temppoductid,ProductCode,'','','',Price,Price,1,
					[Weight],ProductImage,'','',CreateUserID,getdate(),getdate(),'',@ClientID,1 from products where productid=@temppoductid
			set @Err+=@@Error
		end
		--验证明细是否存在 
		declare @detailstrs nvarchar(4000)
		set @detailstrs=''
		while exists(select ID from @TempDetailTable where [Status]=0) 
		begin			
			declare @tempDetailID varchar(50),@detailID varchar(50),@tempremark varchar(300),@quantity int
			set @detailID=''
			select top 1 @tempDetailID=ID,@quantity=Quantity from @TempDetailTable where status=0  

			select  @detailID=ProductDetailID from ProductDetail   where  ProductID=@temppoductid   
			and	remark=(
				select  isnull(remark,'') from ProductDetail  where ProductDetailID =@tempDetailID and ProductID=@ProductID
			)
			if(isnull(@detailID,'')='')
			begin 
				set @detailID=NEWID()
				INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode,BigPrice ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[Status],Remark,IsDefault,
					[Weight],ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID])
				select @detailID,@temppoductid,DetailsCode,BigPrice,'','','',Price,1,Remark,0,
					[Weight],ImgS,ShapeCode,[Description],@UserID,getdate(),getdate(),'',@ClientID from ProductDetail where ProductDetailID=@tempDetailID
				set @Err+=@@Error
				Update Products set HasDetails=1 where ProductID=@temppoductid and HasDetails=0 				
			end
			else
			begin
				update ProductDetail set status=1 where ProductDetailID=@detailID and Status=9
			end
			set @detailstrs=@detailID+':'+cast(@quantity as varchar)+','+@detailstrs
			update @TempDetailTable set [status]=1 where  ID=@tempDetailID
		end
		set @detailstrs=substring(@detailstrs,0,len(@detailstrs))
		set @sql='select ID='''+ replace(@detailstrs,',',''' union all select ''')+''''
		set @sql= replace(@sql,':',''',Quantity=''') 
		insert into @TempTable(ID,Quantity) exec (@sql)
	end

	select identity(int,1,1) as AutoID,ProductDetailID,a.ProductID,UnitID,Quantity,a.Price,a.Remark,
	ProductName,ProductCode,DetailsCode,ProductImage,ImgS  into #TempDetail
	from ProductDetail  a join Products b on a.ProductID=b.ProductID join @TempTable c on c.ID=a.ProductDetailID 	
	where  b.ProductID=@temppoductid   --@ProductID and a.ClientID= case @prociderType when 1 then @ClientID  else @PProviderID end 

	while exists(select AutoID from #TempDetail where AutoID=@AutoID)
	begin	
		select @ProductDetailID=ProductDetailID from #TempDetail where AutoID=@AutoID
		
		if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID)
		begin
			select top 1 @DepotID= DepotID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID
		end
		else
		begin
			select top 1 @DepotID = DepotID from DepotSeat where WareID=@WareID and Status=1
		end

		insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage)
		select @DocID,ProductDetailID,@ProductID,UnitID,'',0,Quantity,Price,Price*Quantity,@WareID,@DepotID,'',0,Remark,@ClientID,ProductName,ProductCode,DetailsCode,isnull(ImgS,ProductImage) from #TempDetail  where  AutoID=@AutoID
		set @Err+=@@Error
		if(@prociderType=2)
		 begin
			insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,DepotID,BatchCode,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,CreateTime,CreateUserID,ProviderID,ProviderName)
			select @OrderID,ProductDetailID,@ProductID,UnitID,'',0,Quantity,Price,Price*Quantity,@DepotID,'',Remark,@PProviderID,ProductName,ProductCode,DetailsCode,isnull(ImgS,ProductImage),GETDATE(),@UserID,@ProviderID,@ProviderName from #TempDetail  where  AutoID=@AutoID
			set @Err+=@@Error
		end		
		set @AutoID=@AutoID+1
	end
	drop table #TempDetail
	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,ProviderID,CreateUserID,CreateTime,OperateIP,ClientID,ProviderName,SourceType)
	values(@DocID,@NewCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,@ProviderID,@UserID,GETDATE(),'',@ClientID,@ProviderName,@SourceType) 
	set @Err+=@@Error
	 if(@prociderType=2)
	 begin
		declare @TypeID nvarchar(64)
		select @TypeID=TypeID from OrderType where TypeCode='SelfServicOrder' and Clientid=@PProviderID
		select top 1 @CustomerID=Customerid,@OwnerID=OwnerID from Customer where ChildClientid=@ClientID and Clientid=@PProviderID
		insert into Orders(OrderID,OrderCode,TypeID,Status,SendStatus,OutStatus,ReturnStatus,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CreateUserID,CreateTime,OperateIP,AgentID,ClientID,SourceType,CustomerID,OwnerID)
		values(@OrderID,@NewCode,isnull(@TypeID,''),1,0,0,0,@TotalMoney,@CityCode,@Address,@PersonName,@MobilePhone,@Remark,@UserID,GETDATE(),'',@AgentID,@PProviderID,2,@CustomerID,@OwnerID)
		set @Err+=@@Error
	end	

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end