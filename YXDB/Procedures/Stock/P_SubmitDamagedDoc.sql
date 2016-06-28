Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_SubmitDamagedDoc')
BEGIN
	DROP  Procedure  P_SubmitDamagedDoc
END

GO
/***********************************************************
过程名称： P_SubmitDamagedDoc
功能描述： 创建报损单据
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录： exec P_SubmitDamagedDoc 
************************************************************/
CREATE PROCEDURE [dbo].[P_SubmitDamagedDoc]
@DocID nvarchar(64),
@DocCode nvarchar(20),
@DocType int,
@TotalMoney decimal(18,2)=0,
@CityCode nvarchar(10)='',
@Address nvarchar(500)='',
@Remark nvarchar(500)='',
@WareID nvarchar(64)='',
@UserID nvarchar(64),
@OperateIP nvarchar(50),
@ClientID nvarchar(64)
AS

begin tran

declare @Err int=0

if exists(select AutoID from ShoppingCart where UserID=@UserID and [GUID]=@WareID and OrderType=@DocType)
begin

	insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS)
	select @DocID,ProductDetailID,ProductID,UnitID,0,Quantity,Price,Quantity*Price,@WareID,DepotID,BatchCode,0,Remark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS 
	from ShoppingCart 
	where UserID=@UserID and [GUID]=@WareID and OrderType=@DocType

	select @TotalMoney=sum(TotalMoney) from StorageDetail where DocID=@DocID

	insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID)
	values(@DocID,@DocCode,@DocType,0,@TotalMoney,@CityCode,@Address,@Remark,@WareID,@UserID,GETDATE(),@OperateIP,@ClientID)

	delete from ShoppingCart  where UserID=@UserID and [GUID]=@WareID and OrderType=@DocType
end
set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end