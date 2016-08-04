Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetGoodsDocByOrderID')
BEGIN
	DROP  Procedure  P_GetGoodsDocByOrderID
END

GO
/***********************************************************
过程名称： P_GetGoodsDocByOrderID
功能描述： 获取单据列表
参数说明：	 
编写日期： 2016/7/14
程序作者： Allen
调试记录： exec P_GetGoodsDocByOrderID 
			
			
************************************************************/
CREATE PROCEDURE [dbo].[P_GetGoodsDocByOrderID]
	@OrderID nvarchar(64)='',
	@TaskID nvarchar(64)='',
	@DocType int,
	@ClientID nvarchar(64)
AS

	Create table #TempDoc(DocID nvarchar(64))

	if(@TaskID='')
	begin
		insert into #TempDoc
		select DocID from GoodsDoc where OrderID=@OrderID and ClientID=@ClientID and DocType=@DocType
	end
	else
	begin
		insert into #TempDoc
		select DocID from GoodsDoc where OrderID=@OrderID and ClientID=@ClientID and DocType=@DocType and TaskID=@TaskID
	end

	select * from GoodsDoc where DocID in (select DocID from #TempDoc) order by CreateTime desc
	--采购单
	select * from GoodsDocDetail where DocID in (select DocID from #TempDoc)

 
 

