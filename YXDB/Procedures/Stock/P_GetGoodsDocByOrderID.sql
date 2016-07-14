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
			@UserID='',
			@KeyWords='',
			@DocType=1,
			@Status=-1,
			@PageSize=10,
			@PageIndex=2,
			@ClientID='b00e97c6-1f93-4f61-aea1-74845af9cf28'
			
************************************************************/
CREATE PROCEDURE [dbo].[P_GetGoodsDocByOrderID]
	@OriginalID nvarchar(64)='',
	@TaskID nvarchar(64)='',
	@DocType int,
	@ClientID nvarchar(64)
AS

	Create table #TempDoc(DocID nvarchar(64))

	if(@TaskID='')
	begin
		insert into #TempDoc
		select DocID from GoodsDoc where OriginalID=@OriginalID and ClientID=@ClientID and DocType=@DocType
	end
	else
	begin
		insert into #TempDoc
		select DocID from GoodsDoc where OriginalID=@OriginalID and ClientID=@ClientID and DocType=@DocType and TaskID=@TaskID
	end

	select * from GoodsDoc where DocID in (select DocID from #TempDoc) order by CreateTime desc
	--采购单
	select * from GoodsDocDetail where DocID in (select DocID from #TempDoc)

 
 

