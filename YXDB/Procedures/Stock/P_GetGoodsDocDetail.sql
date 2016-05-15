Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetGoodsDocDetail')
BEGIN
	DROP  Procedure  P_GetGoodsDocDetail
END

GO
/***********************************************************
过程名称： P_GetGoodsDocDetail
功能描述： 获取产品属性列表
参数说明：	 
编写日期： 2015/5/19
程序作者： Allen
调试记录： exec P_GetGoodsDocDetail '719218bb-9505-4578-915a-b6d7c11d4a5b',''
************************************************************/
CREATE PROCEDURE [dbo].[P_GetGoodsDocDetail]
	@DocID nvarchar(64),
	@ClientID nvarchar(64)
AS

select * from GoodsDoc where DocID=@DocID 

select * from GoodsDocDetail where DocID=@DocID

 

