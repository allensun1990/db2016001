Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetCategoryDetailByID')
BEGIN
	DROP  Procedure  P_GetCategoryDetailByID
END

GO
/***********************************************************
过程名称： P_GetCategoryDetailByID
功能描述： 获取产品分类详情
参数说明：	 
编写日期： 2015/6/1
程序作者： Allen
调试记录： exec P_GetCategoryDetailByID 'B27D6489-3B3C-4A78-B28C-E334AD776B61'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetCategoryDetailByID]
	@CategoryID nvarchar(64)
AS

select * from Category where CategoryID=@CategoryID

select AttrID,[Type] from CategoryAttr where Status=1 and CategoryID= @CategoryID 



 

