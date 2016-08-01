Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductDetails')
BEGIN
	DROP  Procedure  P_GetProductDetails
END

GO
/***********************************************************
过程名称： P_GetProductDetails
功能描述： 获取产品明细列表
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录  exec P_GetProductDetails 
		  @keyWords='New',
		  @ClientID='eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductDetails]
	@WareID nvarchar(64)='',
	@keyWords nvarchar(4000)='',
	@ClientID nvarchar(64)
AS
	declare @sqlText nvarchar(4000)

	set @sqlText='select d.ProductDetailID,d.ProductID,p.ProductCode,p.ProductName,d.SaleAttrValue,d.StockIn,d.SaleCount,d.Price,B.Name ProviderName,case d.Imgs when '''' then p.ProductImage else d.Imgs end Imgs,d.Description from '

	set @sqlText+=' Products p join ProductDetail d on p.ProductID=d.ProductID and ((p.HasDetails=1 and d.IsDefault=0) or (p.HasDetails=0 and d.IsDefault=1)) left join Providers B on P.ProviderID=B.ProviderID '

	set @sqlText+='where p.ClientID='''+@ClientID+''' and P.Status<>9 and d.Status<>9 '

	if(@WareID<>'')
	begin
		set @sqlText+=' and p.ProductDetailID in (select ProductDetailID from ProductStock where WareID='''+@WareID+''')'
	end

	if(@keyWords <> '')
	begin
		set @sqlText +=' and (p.ProductName like ''%'+@keyWords+'%'' or B.Name like ''%'+@keyWords+'%'' or  p.ProductCode like ''%'+@keyWords+'%'' or d.DetailsCode like ''%'+@keyWords+'%'') '
	end

	exec(@sqlText)
 

