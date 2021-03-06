﻿Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertStoreDocPart')
BEGIN
	DROP  Procedure  P_InsertStoreDocPart
END

GO
/***********************************************************
过程名称： P_InsertStoreDocPart
功能描述： 生成未审核的入库单
参数说明： @Remarks 格式 智能工厂产品ID1:规格名称,规格名称,智能工厂产品ID2:规格名称,....
		   @Nums 数量1,数量2,数量3,...
编写日期： 2016/8/22
程序作者： Michaux
调试记录： exec P_InsertStoreDocPart 
************************************************************/
create proc P_InsertStoreDocPart 
@BillingCode varchar(64),
@Remarks Varchar(4000),
@Nums varchar(2000),
@OrderID varchar(50),
@UserID varchar(50),
@AutoID varchar(50),
@ErrInfo nvarchar(500) output
as

declare @Err int=0,@remark varchar(200),@i int,@j int ,@NewDocID varchar(64) ,@TempRemarks varchar(4000),@TempNums varchar(2000),@Quantity int ,@pid varchar(64),@Status int
select  @NewDocID=newid(), @TempRemarks=@Remarks, @TempNums=@Nums,@i=CHARINDEX(',',@TempRemarks,0)
begin tran

select @Status=Status from StorageDoc where DocID=@OrderID
if(@Status>1 and  @Status!=3)
begin	
	set @ErrInfo=case @Status when 2 then '采购单已完成操作！' else '采购单已作废' end
	rollback tran
	return -1
end
if(exists(select autoid from StorageDocPart where OriginalID=@OrderID and remark=@AutoID))
begin 
	set @ErrInfo ='此批次发货单已同步，不能重复同步' 
	rollback tran
	return -1
end
while @i>0
begin	
	set @remark=SUBSTRING(@TempRemarks,0,@i)
	set @j=CHARINDEX(',',@TempNums,0)
	set @Quantity=cast(SUBSTRING(@TempNums,0,@j) as int)
	 if(charindex(':[',@remark,0)>0)
	 begin
		set @pid=SUBSTRING(@remark,0,charindex(':[',@remark,0))
		set @remark=SUBSTRING(@remark,charindex(':[',@remark,0)+1,len(@remark))
	 end

	insert into StoragePartDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Complete,Price,TotalMoney,CompleteMoney,WareID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage )
		select @NewDocID,ProductDetailID,ProductID,UnitID,0,@Quantity,@Quantity,Price,Price*@Quantity,Price*@Quantity,WareID,BatchCode,0,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage 
		from StorageDetail  where  DocID=@OrderID and Remark=@remark  and ProductID in (select  ProductID from Products where CMGoodsID=@pid)
	set @TempRemarks=SUBSTRING(@TempRemarks,@i+1,LEN(@TempRemarks))
	set @TempNums=SUBSTRING(@TempNums,@j+1,LEN(@TempNums))
	set @i=CHARINDEX(',',@TempRemarks,0)
end 


if exists(select AutoID from StoragePartDetail where DocID=@NewDocID)
begin
	declare  @RealMoney decimal(18,4)
	select @RealMoney=isnull(sum(CompleteMoney),0) from StoragePartDetail where DocID=@NewDocID

	insert into StorageDocPart(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
		select @NewDocID,@BillingCode,1,0,@RealMoney,CityCode,Address,@AutoID,WareID,'',GETDATE(),'',ClientID,DocID,DocCode from StorageDoc where DocID=@OrderID
 
	update StorageDoc set Status=3 where DocID=@OrderID

	set @Err+=@@error
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end