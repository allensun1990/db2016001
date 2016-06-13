Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductByID')
BEGIN
	DROP  Procedure  P_GetProductByID
END

GO
/***********************************************************
过程名称： P_GetProductByID
功能描述： 获取产品详情
参数说明：	 
编写日期： 2015/7/1
程序作者： Allen
调试记录： exec P_GetProductByID 'CD867D63-B61D-47DE-9C63-0B1A56D68486'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductByID]
	@ProductID nvarchar(64)
AS

select * from Products where ProductID=@ProductID 

if exists(select AutoID from Products where ProductID=@ProductID and HasDetails=1)
begin
	select * from ProductDetail where ProductID=@ProductID and Status<>9 and IsDefault=0
end
else
begin
	select * from ProductDetail where ProductID=@ProductID and Status<>9 and IsDefault=1
end

 

