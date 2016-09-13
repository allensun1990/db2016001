Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeletePlateMaking')
BEGIN
	DROP  Procedure  P_DeletePlateMaking
END

GO
/***********************************************************
过程名称： P_DeletePlateMaking
功能描述： 删除工艺说明
参数说明：	 
编写日期： 2016/5/27
程序作者： MU
调试记录： declare @Result exec P_DeletePlateMaking @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@UserID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_DeletePlateMaking
@PlateID nvarchar(64)
as
	update PlateMaking set status=9 where PlateID=@PlateID
		 





