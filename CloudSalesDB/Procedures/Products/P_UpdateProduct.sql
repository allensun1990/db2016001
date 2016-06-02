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
@DiscountValue decimal(5,4),
@ProductImg nvarchar(4000)='',
@Description text,
@ShapeCode nvarchar(50),
@CreateUserID nvarchar(64),
@ClientID nvarchar(64)
AS

begin tran

declare @Err int,@PIDList nvarchar(max),@SaleAttr  nvarchar(max),@Multiple int

set @Err=0

select @PIDList=PIDList,@SaleAttr=SaleAttr from Category where CategoryID=@CategoryID

if(@BigUnitID=@UnitID)
begin
	set @BigSmallMultiple=1
end

select @Multiple=BigSmallMultiple from [Products] where ProductID=@ProductID

Update [Products] set [ProductName]=@ProductName,ProductCode=@ProductCode,[GeneralName]=@GeneralName,[IsCombineProduct]=@IsCombineProduct,[BrandID]=@BrandID,
						[BigUnitID]=@BigUnitID,[UnitID]=@UnitID,[BigSmallMultiple]=@BigSmallMultiple ,
						[CategoryIDList]=@PIDList,[SaleAttr]=@SaleAttr,[AttrList]=@AttrList,[ValueList]=@ValueList,[AttrValueList]=@AttrValueList,
						[CommonPrice]=@CommonPrice,[Price]=@Price,[PV]=0,[Status]=@Status,ProductImage=@ProductImg,
						[IsNew]=@Isnew,[IsRecommend]=@IsRecommend ,[DiscountValue]=@DiscountValue,[Weight]=@Weight ,[EffectiveDays]=@EffectiveDays,
						IsAllow=@IsAllow,IsAutoSend=@IsAutoSend,
						[ShapeCode]=@ShapeCode ,[Description]=@Description ,[UpdateTime]=getdate()
where ProductID=@ProductID

--处理子产品大单位价格
if(@Multiple<>@BigSmallMultiple)
begin
	if(@BigSmallMultiple=1)
	begin
		update ProductDetail set BigPrice=Price where ProductID=@ProductID
	end
	else
	begin
		update ProductDetail set BigPrice=BigPrice/@Multiple*@BigSmallMultiple where ProductID=@ProductID
	end
	set @Err+=@@Error
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