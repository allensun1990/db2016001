Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateAllAliOrderUpdateLogStatus')
BEGIN
	DROP  Procedure  P_UpdateAllAliOrderUpdateLogStatus
END

GO
/***********************************************************
过程名称： P_UpdateAllAliOrderUpdateLogStatus
功能描述： 修改订单制版属性
参数说明：	 
编写日期： 2016/3/18
程序作者： MU
调试记录： exec P_UpdateAllAliOrderUpdateLogStatus 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateAllAliOrderUpdateLogStatus]
@AliOrderCodes nvarchar(1000)='',
@Status int
AS
begin tran

declare @Err int=0
declare @sql varchar(2000)

if(@Status=1)
set @sql='update AliOrderUpdateLog set Status='+convert(nvarchar(2), @Status)+',UpdateTime=getdate()  where AliOrderCode in (  select AliOrderCode='''+ replace(@AliOrderCodes,'|',''' union all select ''')+''' ) '
else
set @sql='update AliOrderUpdateLog set Status='+convert(nvarchar(2), @Status)+', FailCount=FailCount+1,UpdateTime=getdate()  where AliOrderCode in (  select AliOrderCode='''+ replace(@AliOrderCodes,'|',''' union all select ''')+''' ) '

exec (@sql)

set @Err+=@@ERROR

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 

