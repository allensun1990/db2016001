﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetFilterProducts')
BEGIN
	DROP  Procedure  P_GetFilterProducts
END

GO
/***********************************************************
过程名称： P_GetFilterProducts
功能描述： 获取产品列表
参数说明：	 
编写日期： 2015/9/5
程序作者： Allen
调试记录：declare @totalCount int ,@pageCount int 
		  exec P_GetFilterProducts 
		  @CategoryID='',
		  @keyWords='',
		  @orderColumn=' pd.Price ',
		  @isAsc=0,
		  @pageSize=20,
		  @pageIndex=1,
		  @totalCount =@totalCount,
		  @pageCount =@pageCount,
		  @ClientID='d583bf9e-1243-44fe-ac5c-6fbc118aae36'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetFilterProducts]
	@CategoryID nvarchar(64),
	@DocType int=-1,
	@BeginPrice nvarchar(20)='',
	@EndPrice nvarchar(20)='',
	@IsPublic int=-1,
	@AttrWhere nvarchar(4000)='',
	@SaleWhere nvarchar(4000)='',
	@keyWords nvarchar(4000),
	@orderColumn nvarchar(500)='',
	@isAsc int=0,
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output,
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100)
	

	set @tableName='Products P join ProductDetail pd on p.ProductID=pd.ProductID and ((p.HasDetails=1 and pd.IsDefault=0) or (p.HasDetails=0 and pd.IsDefault=1)) '
	set @columns='P.ProductID,P.ProductName,p.CommonPrice,pd.Price,pd.Description,pd.Remark,
				  case pd.Imgs when '''' then p.ProductImage else pd.Imgs end Imgs,p.SaleCount,pd.ProductDetailID,pd.SaleAttrValue '
	set @key='pd.AutoID'
	set @condition=' P.Status=1 and pd.Status=1 '

	if(@IsPublic=-1)
	begin
		set @condition+=' and (P.ClientID='''+@ClientID+''' or p.IsPublic=2)'
	end
	else if(@IsPublic=1)
	begin
		set @condition+=' and P.ClientID='''+@ClientID+''''
	end
	else if(@IsPublic=2)
	begin
		set @condition+=' and p.IsPublic=2 and P.ClientID<>'''+@ClientID+''''
	end

	if(@CategoryID<>'' and @CategoryID<> '-1')
	begin
		set @condition +=' and P.CategoryIDList like ''%'+@CategoryID+'%'''
	end

	if(@BeginPrice<>'')
	begin
		set @condition +=' and pd.Price>='+@BeginPrice
	end

	if(@EndPrice<>'')
	begin
		set @condition +=' and pd.Price<='+@EndPrice
	end

	if(@keyWords <> '')
	begin
		set @condition +=' and (ProductName like ''%'+@keyWords+'%'' or  ProductCode like ''%'+@keyWords+'%'' or  GeneralName like ''%'+@keyWords+'%'') '
	end

	if(@DocType=11)
	begin
		set @condition +=' and P.Status=1 and pd.Status=1 '
	end

	set @condition += @AttrWhere

	if(@SaleWhere!='')
	begin
		set @condition += ' and pd.AutoID in (select AutoID from ProductDetail where  Status=1 '+@SaleWhere+' )'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 

	select @totalCount=@total,@pageCount =@page
 

