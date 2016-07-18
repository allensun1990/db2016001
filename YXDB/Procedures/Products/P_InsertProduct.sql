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
@IsCombineProduct int=0,
@ProdiverID  nvarchar(64)='',
@BrandID nvarchar(64)='',
@BigUnitID nvarchar(64)='',
@SmallUnitID nvarchar(64),
@BigSmallMultiple int=1,
@CategoryID nvarchar(64),
@Status int=1,
@IsPublic int=0,
@AttrList nvarchar(max),
@ValueList nvarchar(max),
@AttrValueList nvarchar(max),
@CommonPrice decimal(18,2)=0,
@Price decimal(18,2),
@Weight decimal(18,2)=0,
@Isnew int=0,
@IsRecommend int=0,
@IsAllow int=0,
@IsAutoSend int=0,
@EffectiveDays int=0,
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

declare @Err int,@PIDList nvarchar(max),@SaleAttr  nvarchar(max)
set @Err=0
set @ProductID=NEWID()

select @PIDList=PIDList,@SaleAttr=SaleAttr from Category where CategoryID=@CategoryID

--if(@BigUnitID=@SmallUnitID)
--begin
--	set @BigSmallMultiple=1
--end

IF(@ProductCode='' or NOT EXISTS(SELECT 1 FROM [Products] WHERE [ProductCode]=@ProductCode and ClientID=@ClientID))--产品编号唯一，编号不存在时才能执行插入
BEGIN
		INSERT INTO [Products]([ProductID],[ProductCode],[ProductName],[GeneralName],[IsCombineProduct],ProdiverID,[BrandID],[BigUnitID],[SmallUnitID],[BigSmallMultiple] ,
						[CategoryID],[CategoryIDList],[SaleAttr],[AttrList],[ValueList],[AttrValueList],[CommonPrice],[Price],[PV],[TaxRate],[Status],IsPublic,
						[OnlineTime],[UseType],[IsNew],[IsRecommend] ,[IsDiscount],[DiscountValue],[SaleCount],[Weight] ,[ProductImage],[EffectiveDays],
						[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsAllow,IsAutoSend,HasDetails)
				 VALUES(@ProductID,@ProductCode,@ProductName,@GeneralName,@IsCombineProduct,@ProdiverID,@BrandID,@BigUnitID,@SmallUnitID,@BigSmallMultiple,
						@CategoryID,@PIDList,@SaleAttr,@AttrList,@ValueList,@AttrValueList,@CommonPrice,@Price,@Price,0,@Status,@IsPublic,
						getdate(),0,@Isnew,@IsRecommend,1,@DiscountValue,0,@Weight,@ProductImg,@EffectiveDays,@ShapeCode,@Description,@CreateUserID,
						getdate(),getdate(),'',@ClientID,@IsAllow,@IsAutoSend,0);

						set @Err+=@@Error

INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[BigPrice],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
				VALUES(NEWID(),@ProductID,'','','','',@Price,@Price,1,
					@Weight,'','','',@CreateUserID,getdate(),getdate(),'',@ClientID,1);


		set @Result=1;
END
ELSE
BEGIN
	set @ProductID='';
	set @Result=0;
END

set @Err+=@@Error

if(@Err>0)
begin
	set @ProductID=''
	rollback tran
end 
else
begin
	commit tran
end