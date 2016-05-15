Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetCustomerByID')
BEGIN
	DROP  Procedure  P_GetCustomerByID
END

GO
/***********************************************************
过程名称： P_GetCustomerByID
功能描述： 获取客户详情
参数说明：	 
编写日期： 2015/11/8
程序作者： Allen
调试记录： exec P_GetCustomerByID 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetCustomerByID]
	@CustomerID nvarchar(64),
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

declare @ActivityID nvarchar(64)

select @ActivityID=ActivityID from Customer where CustomerID=@CustomerID and ClientID=@ClientID

select * from Customer where CustomerID=@CustomerID and ClientID=@ClientID

select * from Contact where 1<>1 and CustomerID=@CustomerID and Status<>9

select * from Activity where ActivityID=@ActivityID
 

