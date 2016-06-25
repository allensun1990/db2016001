Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateProduct')
BEGIN
	DROP  Procedure  P_UpdateProduct
END

GO
/***********************************************************
过程名称： P_UpdateProduct
功能描述： 编辑产品
参数说明：	 
编写日期： 2015/7/2
程序作者： Allen
调试记录： exec P_UpdateProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateProduct]
@ProductID nvarchar(64),
@ProductCode nvarchar(200),
@ProductName nvarchar(200),
@GeneralName nvarchar(200),
@IsCombineProduct int,
@BrandID nvarchar(64),
@BigUnitID nvarchar(64),
@UnitID nvarchar(64),
@BigSmallMultiple int,
@Status int,
@CategoryID nvarchar(64),
@AttrList nvarchar(max),
@ValueList nvarchar(max),
@AttrValueList nvarchar(max),
@CommonPrice decimal(18,2),
@Price decimal(18,2),
@Weight decimal(18,2),
@Isnew int,
@IsRecommend int,
@IsAllow int=0,
@IsAutoSend int=0,
@EffectiveDays int,
@WarnCount int=0,
@DiscountValue decimal(5,4),
@ProductImg nvarchar(4000)='',
@Description text,
@ShapeCode nvarchar(50),
@CreateUserID nvarchar(64),
@ClientID nvarchar(64)
AS

begin tran

IF(@ShapeCode is not null and @ShapeCode<>'' and EXISTS(SELECT AutoID FROM [Products] WHERE ShapeCode=@ShapeCode and ClientID=@ClientID and  ProductID<>@ProductID and Status<>9))--条形码唯一
BEGIN
	rollback tran
	return
END

declare @Err int,@PIDList nvarchar(max),@SaleAttr  nvarchar(max),@HasDetails int=0

set @Err=0

select @PIDList=PIDList,@SaleAttr=SaleAttr from Category where CategoryID=@CategoryID


Update [Products] set [ProductName]=@ProductName,ProductCode=@ProductCode,[GeneralName]=@GeneralName,[IsCombineProduct]=@IsCombineProduct,[BrandID]=@BrandID,
						[BigUnitID]=@BigUnitID,[UnitID]=@UnitID,[BigSmallMultiple]=@BigSmallMultiple ,
						[CategoryIDList]=@PIDList,[SaleAttr]=@SaleAttr,[AttrList]=@AttrList,[ValueList]=@ValueList,[AttrValueList]=@AttrValueList,
						[CommonPrice]=@CommonPrice,[Price]=@Price,[PV]=0,[Status]=@Status,ProductImage=@ProductImg,
						[IsNew]=@Isnew,[IsRecommend]=@IsRecommend ,[DiscountValue]=@DiscountValue,[Weight]=@Weight ,[EffectiveDays]=@EffectiveDays,
						IsAllow=@IsAllow,IsAutoSend=@IsAutoSend,WarnCount=@WarnCount,
						[ShapeCode]=@ShapeCode ,[Description]=@Description ,[UpdateTime]=getdate()
where ProductID=@ProductID

set @Err+=@@Error

update ProductDetail set Price=@Price,ImgS=@ProductImg,DetailsCode=@ProductCode,[Weight]=@Weight where ProductID=@ProductID and IsDefault=1
	
set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end