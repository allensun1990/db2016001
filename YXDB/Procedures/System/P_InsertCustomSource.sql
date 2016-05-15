Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertCustomSource')
BEGIN
	DROP  Procedure  P_InsertCustomSource
END

GO
/***********************************************************
过程名称： P_InsertCustomSource
功能描述： 添加客户来源
参数说明：	 
编写日期： 2015/4/10
程序作者： Allen
调试记录： exec P_InsertCustomSource 
************************************************************/
CREATE PROCEDURE [dbo].[P_InsertCustomSource]
@SourceID nvarchar(64),
@SourceName nvarchar(100),
@SourceCode nvarchar(100),
@IsChoose int=1,
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 编码已存在
AS

begin tran

set @Result=0

declare @Err int=0
 
--编码已存在
if exists(select AutoID from CustomSource where SourceCode=@SourceCode and ClientID=@ClientID)
begin
	set @Result=2
	rollback tran
	return
end

insert into CustomSource(SourceID,SourceName,SourceCode,IsSystem,IsChoose,Status,CreateUserID,ClientID)
                                values(@SourceID,@SourceName,@SourceCode,0,@IsChoose,1,@CreateUserID,@ClientID)
set @Err+=@@error

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end