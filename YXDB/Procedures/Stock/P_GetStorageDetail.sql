Use IntFactory
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
调试记录： exec P_GetStorageDetail 'c2d6e4e4-8ea4-49ad-b17a-c98963f57628',''
************************************************************/
CREATE PROCEDURE [dbo].[P_GetStorageDetail]
	@DocID nvarchar(64),
	@ClientID nvarchar(64)
AS

select * from StorageDoc where DocID=@DocID 

select s.*,d.DepotCode from StorageDetail s left join DepotSeat d on s.DepotID=d.DepotID where DocID=@DocID 
 

