Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetAttrsByClientID')
BEGIN
	DROP  Procedure  P_GetAttrsByClientID
END

GO
/***********************************************************
过程名称： P_GetAttrsByClientID
功能描述： 获取产品属性列表
参数说明：	 
编写日期： 2015/11/20
程序作者： Allen
调试记录： exec P_GetAttrsByClientID '2edb2172-403d-4561-a28f-8d9898ee7156'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetAttrsByClientID]
	@ClientID nvarchar(64)
AS

select * from ProductAttr where ClientID=@ClientID and Status<>9

select * from AttrValue where  ClientID=@ClientID and Status<>9
 

