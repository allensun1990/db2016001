Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductsByKeywords_Stock')
BEGIN
	DROP  Procedure  P_GetProductsByKeywords_Stock
END

GO
/***********************************************************
过程名称： P_GetProductsByKeywords_Stock
功能描述： 获取产品列表(单据用)
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录  exec P_GetProductsByKeywords_Stock 
		  @keyWords='',
		  @ClientID='eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductsByKeywords_Stock]
	@WareID nvarchar(64)='',
	@keyWords nvarchar(4000),
	@ClientID nvarchar(64)
AS
	declare @sqlText nvarchar(4000)

	set @sqlText='select s.ProductDetailID,s.ProductID,p.ProductCode,p.ProductName,d.SaleAttrValue,s.StockIn,s.StockOut,w.Name WareName,dm.DepotCode,s.DepotID,d.Remark,d.Description from '

	set @sqlText+=' ProductStock s 
					join Products p on s.ProductID=p.ProductID 
					join ProductDetail d on s.ProductDetailID=d.ProductDetailID
					join WareHouse w on s.WareID=w.WareID
					join DepotSeat dm on s.DepotID=dm.DepotID '

	set @sqlText+='where s.ClientID='''+@ClientID+''' and P.Status<>9 and d.Status<>9 and s.StockIn>s.StockOut '

	if(@WareID<>'')
	begin
		set @sqlText+=' and s.WareID='''+@WareID+''''
	end

	if(@keyWords <> '')
	begin
		set @sqlText +=' and (p.ProductName like ''%'+@keyWords+'%'' or  p.ProductCode like ''%'+@keyWords+'%'' or dm.DepotCode like ''%'+@keyWords+'%'') '
	end

	exec(@sqlText)
 

