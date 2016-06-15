use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateClientOrderAccountStatus')
BEGIN
	DROP  Procedure  M_UpdateClientOrderAccountStatus
END

GO

/***********************************************************
过程名称： M_UpdateClientOrderAccountStatus
功能描述： 后台订单账目审核或删除
参数说明：	 
编写日期： 2016/05/19
程序作者： Michaux
调试记录： 
************************************************************/

create proc [dbo].[M_UpdateClientOrderAccountStatus]
@Result int output, 
@AutoID nvarchar(64),
@PayStatus int =0
as
begin
declare @status int
set @Status=-1
set @Result=0
select @Status=status from ClientOrderAccount where AutoID=@AutoID

if(@Status>0)
begin
	set @Result= case @status when 1 then 1001 else 1002 end
	return 0;
end

update ClientOrderAccount set Status=@PayStatus where AutoID=@AutoID 
set @Result=1
return @Result;


end

GO