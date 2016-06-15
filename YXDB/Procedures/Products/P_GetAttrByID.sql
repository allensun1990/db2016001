Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetAttrByID')
BEGIN
	DROP  Procedure  P_GetAttrByID
END

GO
/***********************************************************
过程名称： P_GetAttrByID
功能描述： 获取产品属性
参数说明：	 
编写日期： 2015/5/19
程序作者： Allen
调试记录： exec P_GetAttrByID '2edb2172-403d-4561-a28f-8d9898ee7156'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetAttrByID]
	@AttrID nvarchar(64)
AS

select * from ProductAttr where AttrID=@AttrID 

select * from AttrValue where Status<>9 and AttrID=@AttrID Order by Sort asc ,AutoID desc
 

