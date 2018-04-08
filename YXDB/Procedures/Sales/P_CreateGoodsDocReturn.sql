Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateGoodsDocReturn')
BEGIN
	DROP  Procedure  P_CreateGoodsDocReturn
END

GO
/***********************************************************
过程名称： P_CreateGoodsDocReturn
功能描述： 创建成品退回单据
参数说明：	 
编写日期： 2016/3/9
程序作者： Allen
调试记录： exec P_CreateGoodsDocReturn 'a0020b2d-e2b2-4f7f-9774-628759f3513f',
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateGoodsDocReturn]
	@DocID nvarchar(64),
	@OrderID nvarchar(64),
	@TaskID nvarchar(64)='',
	@DocType int,
	@DocCode nvarchar(50),
	@GoodDetails nvarchar(4000),
	@OriginalID nvarchar(64),
	@ExpressID nvarchar(64)='',
	@ExpressCode nvarchar(50)='',
	@Remark nvarchar(4000)='',
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64),
	@Result int output
AS
begin tran

set @Result=0

declare @Err int=0,@OrderStatus int,@OwnerID nvarchar(64),@OrderCode nvarchar(64),@AutoID int=1,@GoodsQuantity nvarchar(200),@sql nvarchar(4000),
@GoodsDetailID nvarchar(64),@Quantity int,@TotalMoney decimal(18,4),@DocImage nvarchar(4000),@DocImages nvarchar(64),
@OrderType int,@TotalQuantity int=0,@CreateTime datetime,@ProcessID nvarchar(64)

select @OrderStatus=OrderStatus,@OrderCode=OrderCode,@DocImage=OrderImage,@DocImages=OrderImages,@OrderType=OrderType
from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

select @OwnerID=OwnerID,@CreateTime=CreateTime,@ProcessID=ProcessID from GoodsDoc where DocID=@OriginalID

--进行的订单才能操作
if(@OrderStatus<>1)
begin
	set @Result=3
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
		set @GoodsDetailID= convert(nvarchar(64), SUBSTRING (@GoodsQuantity , 1 , CHARINDEX ('|' , @GoodsQuantity )-1))

		set @Quantity=convert(int, SUBSTRING (@GoodsQuantity , CHARINDEX ('|' , @GoodsQuantity)+1 ,LEN(@GoodsQuantity)- CHARINDEX ('|' , @GoodsQuantity)))

		if(@Quantity is null or @Quantity=0)
		begin
			set @AutoID+=1
			continue;
		end

		--大于最大退回数
		if exists(select AutoID from GoodsDocDetail where DocID=@OriginalID and  GoodsDetailID=@GoodsDetailID and ReturnQuantity+@Quantity>Quantity)
		begin
			set @Result=2
			rollback tran
			return
		end

		Update GoodsDocDetail set ReturnQuantity=ReturnQuantity+@Quantity where DocID=@OriginalID and  GoodsDetailID=@GoodsDetailID
		--车缝退回
		if(@DocType=6)
		begin
			if(@ProcessID is null or @ProcessID='')
			begin
				Update OrderGoods set Complete=Complete-@Quantity where OrderID=@OrderID and GoodsDetailID=@GoodsDetailID
			end
		end
		else if(@DocType=21)
		begin
			Update OrderGoods set CutQuantity=CutQuantity-@Quantity where OrderID=@OrderID and GoodsDetailID=@GoodsDetailID
		end
		else if(@DocType=22)
		begin
			Update OrderGoods set SendQuantity=SendQuantity-@Quantity,ReturnQuantity=ReturnQuantity+@Quantity where OrderID=@OrderID and GoodsDetailID=@GoodsDetailID
		end
		insert into GoodsDocDetail(DocID,GoodsDetailID,GoodsID,UnitID,Quantity,Complete,SurplusQuantity,Price,TotalMoney,WareID,DepotID,Status,Remark,ClientID)
				select @DocID,GoodsDetailID,GoodsID,'',@Quantity,0,0,Price,0,'','',0,Remark,@ClientID 
				from GoodsDocDetail where DocID=@OriginalID and  GoodsDetailID=@GoodsDetailID
		--汇总数量
		set @TotalQuantity+=@Quantity
	end
	set @AutoID+=1
end

if exists(select AutoID from GoodsDocDetail where DocID=@DocID)
begin
	insert into GoodsDoc(DocID,DocCode,DocType,DocImage,DocImages,Status,TotalMoney,Quantity,CityCode,Address,Remark,ExpressID,ExpressCode,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OrderID,OrderCode,TaskID,OwnerID)
			values(@DocID,@DocCode,@DocType,@DocImage,@DocImages,2,0,@TotalQuantity,'','',@Remark,@ExpressID,@ExpressCode,'',@OperateID,@CreateTime,'',@ClientID,@OriginalID,@OrderID,@OrderCode,@TaskID,@OwnerID)

	set @Err+=@@error
end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end


