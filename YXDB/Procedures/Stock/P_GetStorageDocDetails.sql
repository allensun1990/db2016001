Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetStorageDocDetails')
BEGIN
	DROP  Procedure  P_GetStorageDocDetails
END

GO
/***********************************************************
过程名称： P_GetStorageDocDetails
功能描述： 获取单据明细列表
参数说明：	 
编写日期： 2016/7/16
程序作者： Allen
调试记录： exec P_GetStorageDocDetails '25A3D084-7CE9-42ED-8BA6-5DDC26B30569'
			
			
************************************************************/
CREATE PROCEDURE [dbo].[P_GetStorageDocDetails]
	@DocID nvarchar(64)=''
AS

	select DocID into #TempDoc from StorageDoc where OriginalID=@DocID

	select DocID,DocCode,CreateTime,CreateUserID from StorageDoc where DocID in (select DocID from #TempDoc) order by CreateTime desc

	select * from StorageDetail where DocID in (select DocID from #TempDoc)
 

