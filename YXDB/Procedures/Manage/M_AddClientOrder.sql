Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_AddClientOrder')
BEGIN
	DROP  Procedure  M_AddClientOrder
END

GO
/***********************************************************
过程名称： M_AddClientOrder
功能描述： 添加后台客户订单
参数说明：	 
编写日期： 2015/11/9
程序作者： MU
调试记录： exec M_AddClientOrder 
************************************************************/
CREATE PROCEDURE [dbo].M_AddClientOrder
@OrderID nvarchar(64),
@UserQuantity int,
@Years int,
@Amount decimal(18,4),
@RealAmount decimal(18,4),
@Type int =1,
@PayType int =1,
@SystemType int =2,
@AgentID nvarchar(64),
@ClientiD nvarchar(64),
@CreateUserID nvarchar(64)
AS

--添加客户订单
insert into ClientOrder(OrderID,UserQuantity,Years,Amount,RealAmount,Type,AgentID,ClientiD,CreateUserID,PayType,SystemType)
values(@OrderID,@UserQuantity,@Years,@Amount,@RealAmount,@Type,@AgentID,@ClientiD,@CreateUserID,@PayType,@SystemType)






