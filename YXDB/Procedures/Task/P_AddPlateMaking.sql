Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddPlateMaking')
BEGIN
	DROP  Procedure  P_AddPlateMaking
END

GO
/***********************************************************
过程名称： P_AddPlateMaking
功能描述： 添加工艺说明
参数说明：	 
编写日期： 2016/6/28
程序作者： MU
调试记录： declare @Result exec P_AddPlateMaking @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@UserID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_AddPlateMaking
@PlateID nvarchar(64),
@Title nvarchar(200),
@Remark nvarchar(200),
@Icon nvarchar(200),
@TaskID nvarchar(64),
@OrderID nvarchar(64),
@TypeName nvarchar(50),
@UserID nvarchar(64)
as
	begin tran

	declare @Err int=0
	insert into  PlateMaking(PlateID,Title,Remark,Icon,TaskID,OrderID,TypeName,CreateUserID,CreateTime) 
			values(@PlateID,@Title,@Remark,@Icon,@TaskID,@OrderID,@TypeName,@UserID,getdate())
			set @Err+=@@ERROR

	if(@Err>0)
	begin
		rollback tran
	end 
	else
	begin
		commit tran
	end

		 





