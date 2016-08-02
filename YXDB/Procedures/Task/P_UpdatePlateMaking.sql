Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdatePlateMaking')
BEGIN
	DROP  Procedure  P_UpdatePlateMaking
END

GO
/***********************************************************
过程名称： P_UpdatePlateMaking
功能描述： 更新工艺说明
参数说明：	 
编写日期： 2016/5/27
程序作者： MU
调试记录： exec P_UpdatePlateMaking '50a9187a-2535-4f55-8f36-9290b8763085','22','11','',3
************************************************************/
CREATE PROCEDURE [dbo].P_UpdatePlateMaking
@PlateID nvarchar(64),
@Title nvarchar(200),
@Remark nvarchar(200),
@Icon nvarchar(200),
@TypeName nvarchar(200)
as
	begin tran
	declare @Err int=0

	update PlateMaking set Title=@Title,Remark=@Remark,Icon=@Icon,TypeName=@TypeName where PlateID=@PlateID
	set @Err+=@@ERROR

	if(@Err>0)
	begin
		rollback tran
	end 
	else
	begin
		commit tran
	end


		 





