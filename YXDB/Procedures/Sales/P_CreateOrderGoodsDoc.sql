Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrderGoodsDoc')
BEGIN
	DROP  Procedure  P_CreateOrderGoodsDoc
END

GO
/***********************************************************
过程名称： P_CreateOrderGoodsDoc
功能描述： 创建成品单据
参数说明：	 
编写日期： 2016/3/9
程序作者： Allen
调试记录： exec P_CreateOrderGoodsDoc 'a0020b2d-e2b2-4f7f-9774-628759f3513f',
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrderGoodsDoc]
	@DocID nvarchar(64),
	@OrderID nvarchar(64),
	@TaskID nvarchar(64)='',
	@DocType int,
	@DocCode nvarchar(50),
	@GoodDetails nvarchar(4000),
	@IsOver int=0,
	@ExpressID nvarchar(64)='',
	@ExpressCode nvarchar(50)='',
	@Remark nvarchar(4000)='',
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
begin tran

declare @Err int=0,@Status int,@OwnerID nvarchar(64),@OrderCode nvarchar(64),@AutoID int=1,@GoodsQuantity nvarchar(200),@sql nvarchar(4000),@CutStatus int,
@GoodsAutoID int,@Quantity int,@TotalMoney decimal(18,4),@DocImage nvarchar(4000),@DocImages nvarchar(64),@AliOrderCode nvarchar(100)='',@ProcessID nvarchar(64),
@OrderType int,@TotalQuantity int=0

select @Status=Status,@OwnerID=OwnerID,@OrderCode=OrderCode,@DocImage=OrderImage,@DocImages=OrderImages,@AliOrderCode=AliOrderCode,@ProcessID=ProcessID,@OrderType=OrderType ,@CutStatus=CutStatus
from Orders where OrderID=@OrderID and ClientID=@ClientID

--打样单
if(@OrderType=1)
begin
	
	if(@Status<>1 and @Status<>2)
	begin
		rollback tran
		return
	end

	insert into GoodsDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,CityCode,Address,Remark,ExpressID,ExpressCode,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode,TaskID)
			values(@DocID,@DocCode,@DocType,@DocImage,@DocImages,2,0,'','',@Remark,@ExpressID,@ExpressCode,'',@OperateID,GETDATE(),'',@ClientID,@OrderID,@OrderCode,@TaskID)

	commit tran
	return
end

if(@Status<>5)
begin
	rollback tran
	return
end

create table #TempTable(ID int identity(1,1),Value nvarchar(4000))
set @sql='select col='''+ replace(@GoodDetails,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)

while exists(select ID from #TempTable where ID=@AutoID)
begin
	select @GoodsQuantity=Value from #TempTable where ID=@AutoID
	if(LEN(@GoodsQuantity)>0)
	begin
		set @GoodsAutoID= convert(int, SUBSTRING (@GoodsQuantity , 1 , CHARINDEX ('-' , @GoodsQuantity )-1))

		set @Quantity=convert(int, SUBSTRING (@GoodsQuantity , CHARINDEX ('-' , @GoodsQuantity)+1 ,LEN(@GoodsQuantity)- CHARINDEX ('-' , @GoodsQuantity)))

		--裁剪
		if(@DocType=1)
		begin
			Update OrderGoods set CutQuantity=CutQuantity+@Quantity where OrderID=@OrderID and AutoID=@GoodsAutoID

			insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,ProdiverID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'','',@Quantity,CutQuantity,Quantity-CutQuantity,Price,Price*@Quantity,'','','',0,Remark,@ClientID 
				from OrderGoods where OrderID=@OrderID and AutoID=@GoodsAutoID
		end
		--发货
		else if(@DocType=2)
		begin
			--大于最大可发货
			if exists(select AutoID from OrderGoods where OrderID=@OrderID and AutoID=@GoodsAutoID and SendQuantity+@Quantity>Complete)
			begin
				rollback tran
				return
			end

			Update OrderGoods set SendQuantity=SendQuantity+@Quantity where OrderID=@OrderID and AutoID=@GoodsAutoID

			insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,ProdiverID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'','',@Quantity,SendQuantity,Complete-SendQuantity,Price,Price*@Quantity,'','','',0,Remark,@ClientID 
				from OrderGoods where OrderID=@OrderID and AutoID=@GoodsAutoID
		end
		--车缝
		else if(@DocType=11)
		begin
			--大于最大可完成
			if exists(select AutoID from OrderGoods where OrderID=@OrderID and AutoID=@GoodsAutoID and Complete+@Quantity>CutQuantity)
			begin
				rollback tran
				return
			end

			Update OrderGoods set Complete=Complete+@Quantity where OrderID=@OrderID and AutoID=@GoodsAutoID

			insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,ProdiverID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'','',@Quantity,Complete,CutQuantity-Complete,Price,Price*@Quantity,'','','',0,Remark,@ClientID 
				from OrderGoods where OrderID=@OrderID and AutoID=@GoodsAutoID
		end
		
		--汇总数量
		set @TotalQuantity+=@Quantity
	end
	set @AutoID+=1
end

if exists(select AutoID from GoodsDocDetail where DocID=@DocID)
begin
	--处理材料使用量
	if(@DocType=1)
	begin
		--参数
		declare @ProductID nvarchar(64),@ProductDetailID nvarchar(64),@UseQuantity decimal(18,2),@BatchCode nvarchar(50),@BatchAutoID int,@BatchQuantity decimal(18,4),
		@DRemark nvarchar(4000),@Price decimal(18,4),@UnitID nvarchar(64),@ProviderID nvarchar(64)='',@WareID nvarchar(64),@DepotID nvarchar(64)

		select @AutoID=1,@WareID=WareID from WareHouse where ClientID=@ClientID and Status<>9

		select identity(int,1,1) as AutoID,ProductDetailID,ProductID, UnitID,Quantity+Loss Quantity,Price,'' BatchCode,Remark,ProdiverID,
		ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
		into #TempProducts 
		from OrderDetail where OrderID=@OrderID 

		--批次临时库存表
		create table #BatchStock(AutoID int identity(1,1),DepotID nvarchar(64),BatchCode nvarchar(50),Quantity int)

		while exists(select AutoID from #TempProducts where AutoID=@AutoID)
		begin
			select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@UseQuantity=Quantity*@TotalQuantity,@BatchCode=BatchCode,@DRemark=Remark,@Price=Price,
			@UnitID=UnitID,@ProviderID= ProdiverID
			from #TempProducts where AutoID=@AutoID

			truncate table #BatchStock

			insert into #BatchStock(DepotID,BatchCode,Quantity) 
			select p.DepotID,BatchCode,StockIn-StockOut from ProductStock p join DepotSeat d on p.DepotID=d.DepotID
			where p.WareID=@WareID and ProductID=@ProductID and ProductDetailID=@ProductDetailID and StockIn-StockOut>0 order by d.Sort

			set @BatchAutoID=1

			--遍历货位材料库存
			while exists(select AutoID from #BatchStock where AutoID=@BatchAutoID)
			begin
				select @DepotID=DepotID,@BatchCode=BatchCode,@BatchQuantity=Quantity from #BatchStock where AutoID=@BatchAutoID 

				if(@BatchQuantity>=@UseQuantity)
				begin

					insert into StorageDetail(DocID,ProductDetailID,ProductID,ProdiverID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS )
					select @DocID,@ProductDetailID,@ProductID,@ProviderID,@UnitID,0,@UseQuantity,@Price,@Price*@UseQuantity,@WareID,@DepotID,@BatchCode,0,@DRemark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
					from #TempProducts where AutoID=@AutoID

					update ProductStock set StockOut=StockOut+@UseQuantity where ProductDetailID=@ProductDetailID  and DepotID=@DepotID 
					--处理产品流水
					insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
							values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),2,1,@UseQuantity,@WareID,@DepotID,@OperateID,@ClientID)
			
					set @UseQuantity=0
					break;
				end
				else
				begin
					insert into StorageDetail(DocID,ProductDetailID,ProductID,ProdiverID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS )
					select @DocID,@ProductDetailID,@ProductID,@ProviderID,@UnitID,0,@BatchQuantity,@Price,@Price*@BatchQuantity,@WareID,@DepotID,@BatchCode,0,@DRemark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
					from #TempProducts where AutoID=@AutoID

					update ProductStock set StockOut=StockOut+@BatchQuantity where ProductDetailID=@ProductDetailID  and DepotID=@DepotID 
					--处理产品流水
					insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
							values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),2,1,@BatchQuantity,@WareID,@DepotID,@OperateID,@ClientID)
			
					set @UseQuantity=@UseQuantity-@BatchQuantity
				end

				set @BatchAutoID=@BatchAutoID+1

			end

			if(@UseQuantity > 0)
			begin
				select top 1 @DepotID=p.DepotID from ProductStock p join DepotSeat d on p.DepotID=d.DepotID
				where p.WareID=@WareID and ProductID=@ProductID and ProductDetailID=@ProductDetailID order by d.Sort 

				if exists(select AutoID from ProductStock where  ProductDetailID=@ProductDetailID and DepotID=@DepotID)
				begin
					update ProductStock set StockOut=StockOut+@UseQuantity where ProductDetailID=@ProductDetailID  and DepotID=@DepotID 
				end
				else
				begin
					insert into ProductStock(ProductDetailID,ProductID,StockIn,StockOut,LogicOut,BatchCode,WareID,DepotID,ClientID)
								values (@ProductDetailID,@ProductID,0,@UseQuantity,0,'',@WareID,@DepotID,@ClientID)
				end
				

				--处理产品流水
				insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
							values(@ProductDetailID,@ProductID,@DocID,@DocCode,'',CONVERT(varchar(100), GETDATE(), 112),2,1,@UseQuantity,@WareID,@DepotID,@OperateID,@ClientID)
			end

			set @Err+=@@Error

			set @AutoID=@AutoID+1
		end

		if exists(select AutoID from StorageDetail where DocID= @DocID)
		begin
			select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

			insert into StorageDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
			values(@DocID,@DocCode,2,@DocImage,@DocImages,2,@TotalMoney,'','','大货裁剪单自动生成使用单',@WareID,@OperateID,GETDATE(),'',@ClientID,@OrderID,@OrderCode)
		
		end
	end

	select @TotalMoney=sum(TotalMoney) from GoodsDocDetail where DocID=@DocID

	insert into GoodsDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,Quantity,CityCode,Address,Remark,ExpressID,ExpressCode,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode,TaskID)
			values(@DocID,@DocCode,@DocType,@DocImage,@DocImages,2,@TotalMoney,@TotalQuantity,'','',@Remark,@ExpressID,@ExpressCode,'',@OperateID,GETDATE(),'',@ClientID,@OrderID,@OrderCode,@TaskID)

	set @Err+=@@error
end

if(@IsOver=1)
begin
	if(@DocType=1)
	begin
		Update Orders set CutStatus=2 where OrderID=@OrderID
	end
	else if(@DocType=2 and @CutStatus=2)
	begin
		Update Orders set SendStatus=2,Status=6 where OrderID=@OrderID

		Insert into OrderStatusLog(OrderID,Status,CreateUserID) values(@OrderID,6,@OperateID)

		--通知阿里待处理日志
		if(@AliOrderCode is not null and @AliOrderCode<>'')
		begin
			insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,AgentID,ClientID)
			values(NEWID(),@OrderID,@AliOrderCode,2,0,6,0,0,getdate(),getdate(),'大货单生产完成，发货完毕',@ClientID,@ClientID)
			set @Err+=@@error
		end

		set @Err+=@@error
	end
	
end
else if(@DocType=1)
begin
	Update Orders set CutStatus=1 where OrderID=@OrderID
end
else if(@DocType=2)
begin
	Update Orders set SendStatus=1 where OrderID=@OrderID
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


