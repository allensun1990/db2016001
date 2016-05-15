Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditDamagedDoc')
BEGIN
	DROP  Procedure  P_AuditDamagedDoc
END

GO
/***********************************************************
过程名称： P_AuditDamagedDoc
功能描述： 审核报损单/手工出库单
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_AuditDamagedDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditDamagedDoc]
@DocID nvarchar(64),
@UserID nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@Status int,@DocCode nvarchar(50),@WareID nvarchar(64),@DocType int

select @Status=Status,@DocCode=DocCode,@WareID=WareID,@DocType=DocType from StorageDoc where DocID=@DocID

if(@Status>0)
begin
	set @Result=2 
	set @ErrInfo='单据已完成操作！'
	rollback tran
	return
end

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@BatchCode nvarchar(50),@DepotID nvarchar(64),@Remark nvarchar(4000)


select identity(int,1,1) as AutoID,ProductID,ProductDetailID,Quantity,BatchCode,DepotID,Remark into #TempProducts 
from StorageDetail where DocID=@DocID

while exists(select AutoID from #TempProducts where AutoID=@AutoID)
begin
	
	select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@BatchCode=BatchCode,@DepotID=DepotID,@Remark=Remark from #TempProducts where AutoID=@AutoID

	if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID and BatchCode=@BatchCode and StockIn-StockOut>@Quantity)
	begin
		update ProductStock set StockOut=StockOut+@Quantity where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID and BatchCode=@BatchCode
	end
	else
	begin
		set @Result=4 --库存不足
		select  @ErrInfo='产品：'+ProductName+' '+@Remark+' 批次：'+@BatchCode+'库存不足' from Products where ProductID=@ProductID
		rollback tran
		return
	end
	set @Err+=@@Error

	--处理产品流水
	insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
						values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),@DocType,1,@Quantity,@WareID,@DepotID,@UserID,@ClientID)

	--修改产品入库数
	update Products set LogicOut=LogicOut+@Quantity,SaleCount=SaleCount+@Quantity where ProductID=@ProductID

	--修改产品明细入库数
	update ProductDetail set LogicOut=LogicOut+@Quantity,SaleCount=SaleCount+@Quantity where ProductDetailID=@ProductDetailID
	set @Err+=@@Error

	set @AutoID=@AutoID+1
end


--单据状态
Update StorageDetail set Status=1 where  DocID=@DocID

Update StorageDoc set Status=2 where  DocID=@DocID

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