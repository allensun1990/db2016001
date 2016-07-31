Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertProduct')
BEGIN
	DROP  Procedure  P_InsertProduct
END

GO
/***********************************************************
过程名称： P_InsertProduct
功能描述： 添加产品
参数说明：	 
编写日期： 2015/6/8
程序作者： Allen
调试记录： exec P_InsertProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_InsertProduct]
@ProductCode nvarchar(200),
@ProductName nvarchar(200),
@GeneralName nvarchar(200)='',
@ProviderID  nvarchar(64)='',
@UnitID nvarchar(64),
@CategoryID nvarchar(64),
@Status int=1,
@IsPublic int=0,
@AttrList nvarchar(max),
@ValueList nvarchar(max),
@AttrValueList nvarchar(max),
@CommonPrice decimal(18,2)=0,
@Price decimal(18,2),
@Weight decimal(18,2)=0,
@IsAllow int=0,
@DiscountValue decimal(5,4)=1,
@ProductImg nvarchar(4000),
@Description text,
@ShapeCode nvarchar(50),
@CreateUserID nvarchar(64),
@ClientID nvarchar(64),
@ProductID nvarchar(64) output,
@Result int output--1：成功；0失败
AS

begin tran

set @Result=0


IF(@ProductCode is not null and @ProductCode<>'' and EXISTS(SELECT AutoID FROM [Products] WHERE ProductCode=@ProductCode and ClientID=@ClientID and Status<>9))--编码唯一
BEGIN
	set @ProductID=''
	set @Result=2
	rollback tran
	return
END

declare @Err int,@PIDList nvarchar(max),@SaleAttr  nvarchar(max)
set @Err=0
set @ProductID=NEWID()

select @PIDList=PIDList,@SaleAttr=SaleAttr from Category where CategoryID=@CategoryID

INSERT INTO [Products]([ProductID],[ProductCode],[ProductName],[GeneralName],ProviderID,[UnitID],
				[CategoryID],[CategoryIDList],[SaleAttr],[AttrList],[ValueList],[AttrValueList],[CommonPrice],[Price],[TaxRate],[Status],IsPublic,
				[IsDiscount],[DiscountValue],[SaleCount],[Weight] ,[ProductImage],
				[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsAllow,HasDetails)
			VALUES(@ProductID,@ProductCode,@ProductName,@GeneralName,@ProviderID,@UnitID,
				@CategoryID,@PIDList,@SaleAttr,@AttrList,@ValueList,@AttrValueList,@CommonPrice,@Price,0,@Status,@IsPublic,
				1,@DiscountValue,0,@Weight,@ProductImg,@ShapeCode,@Description,@CreateUserID,
				getdate(),getdate(),'',@ClientID,@IsAllow,0);

set @Err+=@@Error

INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
				VALUES(NEWID(),@ProductID,'','','','',@Price,1,
					@Weight,'','','',@CreateUserID,getdate(),getdate(),'',@ClientID,1);

set @Err+=@@Error

if(@Err>0)
begin
	set @ProductID=''
	rollback tran
end 
else
begin
	set @Result=1;
	commit tran
end