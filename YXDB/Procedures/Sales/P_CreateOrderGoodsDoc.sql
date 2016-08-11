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

declare @Err int=0,@OrderStatus int,@OwnerID nvarchar(64),@OrderCode nvarchar(64),@AutoID int=1,@GoodsQuantity nvarchar(200),@sql nvarchar(4000),@CutStatus int,
@GoodsAutoID int,@Quantity int,@TotalMoney decimal(18,4),@DocImage nvarchar(4000),@DocImages nvarchar(64),@AliOrderCode nvarchar(100)='',@ProcessID nvarchar(64),
@OrderType int,@TotalQuantity int=0

select @OrderStatus=OrderStatus,@OwnerID=OwnerID,@OrderCode=OrderCode,@DocImage=OrderImage,@DocImages=OrderImages,@AliOrderCode=AliOrderCode,@ProcessID=ProcessID,@OrderType=OrderType ,@CutStatus=CutStatus
from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

--进行的订单才能操作
if(@OrderStatus<>1)
begin
	rollback tran
	return
end

--打样单
if(@OrderType=1)
begin
	insert into GoodsDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,CityCode,Address,Remark,ExpressID,ExpressCode,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OrderID,OrderCode,TaskID)
			values(@DocID,@DocCode,@DocType,@DocImage,@DocImages,2,0,'','',@Remark,@ExpressID,@ExpressCode,'',@OperateID,GETDATE(),'',@ClientID,@OrderID,@OrderCode,@TaskID)

	commit tran
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

			insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'',@Quantity,CutQuantity,Quantity-CutQuantity,Price,Price*@Quantity,'','',0,Remark,@ClientID 
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

			insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'',@Quantity,SendQuantity,Complete-SendQuantity,Price,Price*@Quantity,'','',0,Remark,@ClientID 
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

			insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'',@Quantity,Complete,CutQuantity-Complete,Price,Price*@Quantity,'','',0,Remark,@ClientID 
				from OrderGoods where OrderID=@OrderID and AutoID=@GoodsAutoID
		end
		
		--汇总数量
		set @TotalQuantity+=@Quantity
	end
	set @AutoID+=1
end

if exists(select AutoID from GoodsDocDetail where DocID=@DocID)
begin

	select @TotalMoney=sum(TotalMoney) from GoodsDocDetail where DocID=@DocID

	insert into GoodsDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,Quantity,CityCode,Address,Remark,ExpressID,ExpressCode,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OrderID,OrderCode,TaskID)
			values(@DocID,@DocCode,@DocType,@DocImage,@DocImages,2,@TotalMoney,@TotalQuantity,'','',@Remark,@ExpressID,@ExpressCode,'',@OperateID,GETDATE(),'',@ClientID,@OrderID,@OrderCode,@TaskID)

	set @Err+=@@error
end

if(@DocType=1)
begin
	Update Orders set CutStatus=1 where OrderID=@OrderID
end
else if(@DocType=2)
begin
	
	Update Orders set SendStatus=1,SendQuantity=SendQuantity+@TotalQuantity,TotalMoney=(SendQuantity+@TotalQuantity)*FinalPrice where OrderID=@OrderID
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


