Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderCategory')
BEGIN
	DROP  Procedure  P_UpdateOrderCategory
END

GO
/***********************************************************
过程名称： P_UpdateOrderCategory
功能描述： 编辑加工品类
参数说明：	 
编写日期： 2016/3/4
程序作者： Allen
调试记录： exec P_UpdateOrderCategory 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderCategory]
@CategoryID nvarchar(64),
@PID nvarchar(64)='',
@Status int,
@ClientID nvarchar(64)=''
AS

begin tran


declare @Err int=0

--添加品类 
if(@Status=1)
begin
	if not exists(select AutoID from OrderCategory where CategoryID=@CategoryID and ClientID=@ClientID)
	begin
		Insert into OrderCategory(CategoryID,Layers,ClientID,PID) values(@CategoryID,2,@ClientID,@PID)
	end
	if not exists(select AutoID from OrderCategory where CategoryID=@PID and ClientID=@ClientID)
	begin
		Insert into OrderCategory(CategoryID,Layers,ClientID,PID) values(@PID,1,@ClientID,'')
	end
end
--删除品类
else
begin
	if exists(select AutoID from OrderCategory where CategoryID=@CategoryID and ClientID=@ClientID)
	begin
		delete from OrderCategory where CategoryID=@CategoryID and ClientID=@ClientID
	end
	if not exists(select AutoID from OrderCategory where PID=@PID and ClientID=@ClientID)
	begin
		delete from OrderCategory where CategoryID=@PID and ClientID=@ClientID
	end
end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end