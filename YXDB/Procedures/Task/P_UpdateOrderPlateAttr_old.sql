Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderPlateAttr')
BEGIN
	DROP  Procedure  P_UpdateOrderPlateAttr
END

GO
/***********************************************************
过程名称： P_UpdateOrderPlateAttr
功能描述： 修改订单制版属性
参数说明：	 
编写日期： 2016/3/7
程序作者： MU
调试记录： exec P_UpdateOrderPlateAttr 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderPlateAttr]
@OrderID nvarchar(64),
@TaskID nvarchar(64),
@Platehtml text,
@ValueIDS nvarchar(2000)='',
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS
begin tran

declare @Err int=0
declare @sql varchar(2000)

update orders set Platemaking=@Platehtml where orderid=@OrderID
set @Err+=@@ERROR

delete from OrderTaskPlateAttr where TaskID=@TaskID and OrderID=@OrderID
set @Err+=@@ERROR

set @sql='insert into OrderTaskPlateAttr(TaskID,OrderID,ValueID,CreateTime,CreateUserID,AgentID,ClientID) select '''+@TaskID+''','''+@OrderID+''' ,valueid,getdate(),'''+@CreateUserID+''','''+@AgentID+''','''+@ClientID+'''  from (  select valueid='''+ replace(@ValueIDS,'|',''' union all select ''')+''' ) as valueTB'
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

 

