﻿Use IntFactory
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
修改信息: Michaux 2016/05/18 添加订单来源
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
@ClientiD nvarchar(64),
@CreateUserID nvarchar(64),
@SourceType int=0
AS

--添加客户订单
insert into ClientOrder(OrderID,UserQuantity,Years,Amount,RealAmount,Type,ClientiD,CreateUserID,PayType,SystemType,SourceType)
values(@OrderID,@UserQuantity,@Years,@Amount,@RealAmount,@Type,@ClientiD,@CreateUserID,@PayType,@SystemType,@SourceType)






