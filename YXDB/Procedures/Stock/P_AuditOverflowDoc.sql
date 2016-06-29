Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditOverflowDoc')
BEGIN
	DROP  Procedure  P_AuditOverflowDoc
END

GO
/***********************************************************
过程名称： P_AuditOverflowDoc
功能描述： 审核报溢单
参数说明：	 
编写日期： 2015/12/12
程序作者： Allen
调试记录： exec P_AuditOverflowDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditOverflowDoc]
@DocID nvarchar(64),
@UserID nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@Status int,@DocCode nvarchar(50),@WareID nvarchar(64),@DocType int

select @Status=Status,@DocCode=DocCode,@WareID=WareID,@DocType=DocType from StorageDoc where DocID=@DocID and ClientID=@ClientID

if(@Status>0)
begin
	set @Result=2 
	set @ErrInfo='报溢单已完成操作！'
	rollback tran
	return
end

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@BatchCode nvarchar(50),@DepotID nvarchar(64)


select identity(int,1,1) as AutoID,ProductID,ProductDetailID,Quantity,BatchCode,DepotID into #TempProducts 
from StorageDetail where DocID=@DocID

while exists(select AutoID from #TempProducts where AutoID=@AutoID)
begin
	
	select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@BatchCode=BatchCode,@DepotID=DepotID from #TempProducts where AutoID=@AutoID


	--处理材料库存
	if exists(select AutoID from ClientProducts where ProductID=@ProductID and ClientID=@ClientID)
	begin
		Update ClientProducts set StockIn=StockIn+@Quantity where  ProductID=@ProductID and ClientID=@ClientID
	end
	else
	begin
		insert into ClientProducts(ProductID,ClientID,StockIn,StockOut,LogicOut)
							values(@ProductID,@ClientID,@Quantity,0,0)
	end
	set @Err+=@@Error

	--处理材料规格库存
	if exists(select AutoID from ClientProductDetails where ProductDetailID=@ProductDetailID and ClientID=@ClientID)
	begin
		Update ClientProductDetails set StockIn=StockIn+@Quantity where  ProductDetailID=@ProductDetailID and ClientID=@ClientID
	end
	else
	begin
		insert into ClientProductDetails(ProductID,ProductDetailID,ClientID,StockIn,StockOut,LogicOut)
							values(@ProductID,@ProductDetailID,@ClientID,@Quantity,0,0)
	end
	set @Err+=@@Error

	--处理材料库存明细
	if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID and ClientID=@ClientID)
	begin
		update ProductStock set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID and ClientID=@ClientID
	end
	else
	begin
		insert into ProductStock(ProductDetailID,ProductID,StockIn,StockOut,BatchCode,WareID,DepotID,ClientID)
							values (@ProductDetailID,@ProductID,@Quantity,0,@BatchCode,@WareID,@DepotID,@ClientID)
	end
	set @Err+=@@Error

	--处理产品流水
	insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
						values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),@DocType,0,@Quantity,@WareID,@DepotID,@UserID,@ClientID)

	--修改产品入库数
	--update Products set StockIn=StockIn+@Quantity where ProductID=@ProductID

	--修改产品明细入库数
	--update ProductDetail set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID
	set @Err+=@@Error

	set @AutoID=@AutoID+1
end


--单据状态
Update StorageDetail set Status=1 where  DocID=@DocID

Update StorageDoc set Status=2 where DocID=@DocID

--记录审核日志
insert into StorageDocAction(DocID,Remark,CreateTime,CreateUserID,OperateIP)
					values( @DocID,'审核单据',getdate(),@UserID,'')

set @Err+=@@Error
if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end