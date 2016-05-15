Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_AddClientOrderDetail')
BEGIN
	DROP  Procedure  M_AddClientOrderDetail
END

GO
/***********************************************************
过程名称： M_AddClientOrderDetail
功能描述： 添加后台客户订单详情
参数说明：	 
编写日期： 2015/11/9
程序作者： MU
调试记录： exec M_AddClientOrderDetail 
************************************************************/
CREATE PROCEDURE [dbo].M_AddClientOrderDetail
@OrderID nvarchar(64),
@ProductID nvarchar(64),
@Price decimal(18,4),
@Quantity int,
@CreateUserID nvarchar(64)
AS

--添加后台客户订单详情
insert into ClientOrderDetail(OrderID,ProductID,Price,Quantity,CreateUserID)
values(@OrderID,@ProductID,@Price,@Quantity,@CreateUserID)




