﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditReturnIn')
BEGIN
	DROP  Procedure  P_AuditReturnIn
END

GO
/***********************************************************
过程名称： P_AuditReturnIn
功能描述： 审核退货入库
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_AuditReturnIn 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditReturnIn]
@DocID nvarchar(64),
@UserID nvarchar(64),
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
	set @ErrInfo='退货单已完成操作！'
	rollback tran
	return
end

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@DepotID nvarchar(64)


select identity(int,1,1) as AutoID,ProductID,ProductDetailID,Quantity,DepotID into #TempProducts 
from StorageDetail where DocID=@DocID

while exists(select AutoID from #TempProducts where AutoID=@AutoID)
begin
	
	select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@DepotID=DepotID from #TempProducts where AutoID=@AutoID

	if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID)
	begin
		update ProductStock set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID and WareID=@WareID and DepotID=@DepotID 
	end
	else
	begin
		insert into ProductStock(ProductDetailID,ProductID,StockIn,StockOut,WareID,DepotID,ClientID)
							values (@ProductDetailID,@ProductID,@Quantity,0,@WareID,@DepotID,@ClientID)
	end
	set @Err+=@@Error

	--处理产品流水
	insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
						values(@ProductDetailID,@ProductID,@DocID,@DocCode,CONVERT(varchar(100), GETDATE(), 112),@DocType,0,@Quantity,@WareID,@DepotID,@UserID,@ClientID)

	--修改产品入库数
	update Products set StockIn=StockIn+@Quantity where ProductID=@ProductID

	--修改产品明细入库数
	update ProductDetail set StockIn=StockIn+@Quantity where ProductDetailID=@ProductDetailID
	set @Err+=@@Error

	set @AutoID=@AutoID+1
end


--单据状态
Update StorageDetail set Status=1 where  DocID=@DocID

Update StorageDoc set Status=2 where  DocID=@DocID

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