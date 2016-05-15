Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductsAll')
BEGIN
	DROP  Procedure  P_GetProductsAll
END

GO
/***********************************************************
过程名称： P_GetProductsAll
功能描述： 获取产品列表
参数说明：	 
编写日期： 2015/6/29
程序作者： Allen
调试记录  declare @totalCount int ,@pageCount int 
		  exec P_GetProductsAll 
		  @CategoryID='ffdcab10-fa72-4463-83e2-f9945874f00b',
		  @keyWords='',
		  @orderColumn=' p.Price ',
		  @isAsc=0,
		  @pageSize=20,
		  @pageIndex=1,
		  @totalCount =@totalCount,
		  @pageCount =@pageCount,
		  @ClientID='d583bf9e-1243-44fe-ac5c-6fbc118aae36'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductsAll]
	@CategoryID nvarchar(64)='',
	@ProdiverID nvarchar(64)='',
	@BeginPrice nvarchar(20)='',
	@EndPrice nvarchar(20)='',
	@keyWords nvarchar(4000),
	@orderColumn nvarchar(500)='',
	@isAsc int=0,
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output,
	@IsPublic int=-1
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100)

	select @tableName='Products P join Providers B on P.ProdiverID=B.ProviderID join Category C on P.CategoryID=C.CategoryID',
	@columns='P.*,B.Name ProviderName,C.CategoryName ',@key='P.AutoID'
	set @condition='P.Status<>9 '
	if(@keyWords <> '')
	begin
		set @condition +=' and (ProductName like ''%'+@keyWords+'%'' or  ProductCode like ''%'+@keyWords+'%'') '
	end

	if(@CategoryID<>'' and @CategoryID<> '-1')
	begin
		set @condition +=' and P.CategoryIDList like ''%'+@CategoryID+'%'''
	end

	if(@ProdiverID<>'')
	begin
		set @condition +=' and p.ProdiverID='''+@ProdiverID+''''
	end

	if(@BeginPrice<>'')
	begin
		set @condition +=' and p.Price>='+@BeginPrice
	end

	if(@EndPrice<>'')
	begin
		set @condition +=' and p.Price<='+@EndPrice
	end

	if(@IsPublic<>-1)
	begin
		set @condition +=' and p.IsPublic='+convert(nvarchar(2), @IsPublic)
	end
	else
	begin
		set @condition +=' and p.IsPublic>0 and p.IsPublic<3'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 

