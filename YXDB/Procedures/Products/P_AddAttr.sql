Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddAttr')
BEGIN
	DROP  Procedure  P_AddAttr
END

GO
/***********************************************************
过程名称： P_AddAttr
功能描述： 添加产品属性
参数说明：	 
编写日期： 2015/7/13
程序作者： Allen
调试记录： exec P_AddAttr 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddAttr]
@AttrID nvarchar(64),
@AttrName nvarchar(200),
@Description nvarchar(4000),
@CategoryID nvarchar(64),
@Type int=1,
@CreateUserID nvarchar(64)
AS

begin tran

declare @Err int
set @Err=0

INSERT INTO ProductAttr([AttrID] ,[AttrName],[Description],CategoryID,[Status],CreateUserID) 
					values(@AttrID ,@AttrName,@Description,@CategoryID,1,@CreateUserID)
set @Err+=@@error

if(@CategoryID is not null and @CategoryID<>'')
begin
	insert into CategoryAttr(CategoryID,AttrID,Status,[Type],CreateUserID)
	values(@CategoryID,@AttrID,1,@Type,@CreateUserID)
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end