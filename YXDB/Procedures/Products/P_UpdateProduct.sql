Use IntFactory
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
@GeneralName nvarchar(200)='',
@IsCombineProduct int=0,
@ProdiverID nvarchar(64)='',
@BrandID nvarchar(64)='',
@BigUnitID nvarchar(64)='',
@SmallUnitID nvarchar(64)='',
@BigSmallMultiple int=1,
@Status int,
@IsPublic int=0,
@CategoryID nvarchar(64),
@AttrList nvarchar(max),
@ValueList nvarchar(max),
@AttrValueList nvarchar(max),
@CommonPrice decimal(18,2)=0,
@Price decimal(18,2),
@Weight decimal(18,2),
@Isnew int,
@IsRecommend int,
@IsAllow int=0,
@IsAutoSend int=0,
@EffectiveDays int=0,
@DiscountValue decimal(5,4),
@ProductImg nvarchar(4000)='',
@Description text,
@ShapeCode nvarchar(50),
@CreateUserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output
AS

set @Result=0

begin tran

declare @Err int,@PIDList nvarchar(max),@SaleAttr  nvarchar(max),@Multiple int,@Public int,@DPrice decimal(18,4)=0

set @Err=0

IF(@ProductCode is not null and @ProductCode<>'' and EXISTS(SELECT AutoID FROM [Products] WHERE ProductCode=@ProductCode and ClientID=@ClientID and  ProductID<>@ProductID and Status<>9))--编码唯一
BEGIN
	set @Result=2
	rollback tran
	return
END

select @PIDList=PIDList,@SaleAttr=SaleAttr from Category where CategoryID=@CategoryID

select @Multiple=BigSmallMultiple,@Public=IsPublic,@DPrice=Price from [Products] where ProductID=@ProductID

if(@Public=2 and @IsPublic=1)
begin
	set @IsPublic=2
end
else if(@Public>2 and @IsPublic=0)
begin
	set @IsPublic=@Public
end

Update [Products] set [ProductName]=@ProductName,ProductCode=@ProductCode,[GeneralName]=@GeneralName,[IsCombineProduct]=@IsCombineProduct,[BrandID]=@BrandID,
						[BigUnitID]=@BigUnitID,[SmallUnitID]=@SmallUnitID,[BigSmallMultiple]=@BigSmallMultiple ,IsPublic=@IsPublic,
						CategoryID=@CategoryID,[CategoryIDList]=@PIDList,[SaleAttr]=@SaleAttr,[AttrList]=@AttrList,[ValueList]=@ValueList,[AttrValueList]=@AttrValueList,
						[CommonPrice]=@CommonPrice,[Price]=@Price,[PV]=0,[Status]=@Status,ProductImage=@ProductImg,
						[IsNew]=@Isnew,[IsRecommend]=@IsRecommend ,[DiscountValue]=@DiscountValue,[Weight]=@Weight ,[EffectiveDays]=@EffectiveDays,
						IsAllow=@IsAllow,IsAutoSend=@IsAutoSend,ProdiverID=@ProdiverID,
						[ShapeCode]=@ShapeCode ,[Description]=@Description ,[UpdateTime]=getdate()
where ProductID=@ProductID

update ProductDetail set Price=@Price,ImgS=@ProductImg,DetailsCode=@ProductCode,[Weight]=@Weight where ProductID=@ProductID and IsDefault=1

update ProductDetail set Price=@Price where ProductID=@ProductID and Price=@DPrice

set @Err+=@@Error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end