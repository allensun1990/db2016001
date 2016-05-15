Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetStorageDetail')
BEGIN
	DROP  Procedure  P_GetStorageDetail
END

GO
/***********************************************************
过程名称： P_GetStorageDetail
功能描述： 获取产品属性列表
参数说明：	 
编写日期： 2015/5/19
程序作者： Allen
调试记录： exec P_GetStorageDetail '719218bb-9505-4578-915a-b6d7c11d4a5b',''
************************************************************/
CREATE PROCEDURE [dbo].[P_GetStorageDetail]
	@DocID nvarchar(64),
	@ClientID nvarchar(64)
AS

select * from StorageDoc where DocID=@DocID 

select s.*,p.ProductName,u.UnitName,d.Imgs
from StorageDetail s 
join ProductDetail d on d.ProductDetailID=s.ProductDetailID
join Products p  on s.ProductID=p.ProductID
join ProductUnit u on s.UnitID=u.UnitID
where s.DocID=@DocID 
 

