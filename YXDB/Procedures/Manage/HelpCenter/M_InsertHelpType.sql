USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_InsertHelpType')
BEGIN
	DROP  Procedure  M_InsertHelpType
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_InsertHelpType
功能描述： 添加帮助中心分类	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_InsertHelpType]
	@TypeID nvarchar(64),
	@Name nvarchar(64),
	@Remark nvarchar(400),
	@ModuleType int,
	@Img nvarchar(200)='',
	@UserID nvarchar(64),
	@Result int output --0：失败，1：成功，2 分类名称已存在
AS
	begin tran

	declare @Err int 
	if exists(select TypeID from M_HelpType where Status<>9 and Name=@Name and ModuleType=@ModuleType)
	begin
		set @Result=2
		rollback tran
		return
	end
	else
	begin		
		insert into M_HelpType (TypeID,Name,Remark,ModuleType,Icon,CreateUserID) values(@TypeID,@Name,@Remark,@ModuleType,@Img,@UserID)
	end
	
	set @Err+=@@error
		if (@Err>0)
		begin
			set @Result=0
			rollback tran
		end
		else
		begin
			set @Result=1
			commit tran
		end





GO

