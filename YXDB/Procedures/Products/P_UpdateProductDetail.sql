Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateProductDetail')
BEGIN
	DROP  Procedure  P_UpdateProductDetail
END

GO
/***********************************************************
过程名称： P_UpdateProductDetail
功能描述： 编辑子产品
参数说明：	 
编写日期： 2015/8/16
程序作者： Allen
调试记录： exec P_UpdateProductDetail 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateProductDetail]
@DetailID nvarchar(64),
@ProductCode nvarchar(200),
@ProductID nvarchar(64),
@AttrList nvarchar(max),
@ValueList nvarchar(max),
@AttrValueList nvarchar(max),
@Price decimal(18,2),
@Weight decimal(18,2),
@Description nvarchar(4000)='',
@Remark nvarchar(500)='',
@ShapeCode nvarchar(50),
@ImgS nvarchar(500),
@Result int output--1：成功；0失败
AS

begin tran

declare @Err int
set @Err=0
set @Result=0

if(@ValueList<>'' and charindex('|',@ValueList)=0 and exists(select AutoID from ProductDetail where ProductID=@ProductID and [AttrValue]=@ValueList  and Status<>9 and ProductDetailID<>@DetailID))
begin
	rollback tran
	return
end

if(@Description='' or exists(select AutoID from ProductDetail where ProductID=@ProductID and replace(Description,' ','')=replace(@Description,' ','') and Status<>9 and ProductDetailID<>@DetailID))
begin
	set @DetailID=''
	rollback tran
	return
end

update ProductDetail set DetailsCode=@ProductCode ,[SaleAttr]=@AttrList,[AttrValue]=@ValueList,[SaleAttrValue]=@AttrValueList,[Price]=@Price,Remark=@Remark,
					[Weight]=@Weight,[ShapeCode]=@ShapeCode ,ImgS=@ImgS,[Description]=@Description ,[UpdateTime]=getdate()
where ProductDetailID=@DetailID

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