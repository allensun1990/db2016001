Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetStorageDocForExcel')
BEGIN
	DROP  Procedure  P_GetStorageDocForExcel
END

GO
/***********************************************************
过程名称： P_GetStorageDocForExcel
功能描述： 获取单据列表
参数说明：	 
编写日期： 2016/7/14
程序作者： Michaux
调试记录： exec P_GetStorageDocForExcel 
			@UserID='2606068a-681c-47df-8338-ddb8fb0e1895',
			@KeyWords='',
			@DocType=1,
			@Status=-1, 
			@ClientID='eda082bc-b848-4de8-8776-70235424fc06'
			
************************************************************/
CREATE PROCEDURE [dbo].[P_GetStorageDocForExcel]
	@UserID nvarchar(64)='',
	@KeyWords nvarchar(4000),
	@Status int=-1,
	@WareID nvarchar(64)='',
	@ProviderID nvarchar(64)='',
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='', 
	@DocType int=1,
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),  @condition nvarchar(4000)
 
	set @tableName ='select s.*,b.ProductImage ,b.ProductCode,b.DetailsCode ,b.ProductName ,b.Remark as DetailRemark, b.UnitID,b.WareID,P.Name as ProviderName,
	 b.Status as DetailStatus ,b.BatchCode ,  b.Quantity ,b.Price as DetailPrice,b.TotalMoney as DetailTotalMoney,b.Complete,
	 b.TaxMoney  as DetailTaxMoney,b.TaxRate as DetailTaxRate, b.ReturnMoney as DetailReturnMoney,b.ReturnPrice  as DetailReturnPrice
	 from StorageDoc s join StorageDetail b  on s.DocID=b.DocID  
	 left join Providers p on s.ProviderID=p.ProviderID
	 where  b.status<>9 '

	set @condition=' and s.ClientID='''+@ClientID+''' and s.Status<>9 and DocType= '+str(@DocType)
	--关键词
	if(@keyWords <> '')
	begin
		set @condition +=' and (DocCode like ''%'+@KeyWords+'%'' or  s.PersonName like ''%'+@KeyWords+'%'' or  s.MobileTele like ''%'+@KeyWords+'%'' or s.OriginalCode like ''%'+@KeyWords+'%'') '
	end
	--创建人
	if(@UserID<>'')
	begin
		set @condition += ' and s.CreateUserID='''+@UserID+''''
	end
	if(@WareID<>'')
	begin
		set @condition += ' and s.WareID='''+@WareID+''''
	end

	if(@ProviderID<>'')
	begin
		set @condition += ' and s.ProviderID='''+@ProviderID+''''
	end

	--状态
	if(@Status<>-1)
	begin
		set @condition += ' and s.Status='+str(@Status)
	end
	if(@BeginTime<>'')
		set @condition +=' and s.CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and s.CreateTime <=  '''+@EndTime+' 23:59:59'''

	 
 exec (@tableName+@condition +' order  by s.CreateTime desc ')

