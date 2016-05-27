Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeletetOrderStage')
BEGIN
	DROP  Procedure  P_DeletetOrderStage
END

GO
/***********************************************************
过程名称： P_DeletetOrderStage
功能描述： 删除订单阶段状态
参数说明：	 
编写日期： 2016/1/30
程序作者： Allen
调试记录： exec P_DeletetOrderStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeletetOrderStage]
@StageID nvarchar(64),
@ProcessID nvarchar(64),
@UserID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

if not exists(select AutoID from OrderStage where ProcessID=@ProcessID and StageID<>@StageID and Status=1)
begin
	return
end

begin tran

declare @Err int=0,@Sort int=0,@Mark int=0,@Status int=1,@PrevStageID nvarchar(64)

select @Sort=Sort,@Mark=Mark,@Status=Status from OrderStage where StageID=@StageID and ProcessID=@ProcessID
if(@Status=1)
begin
	--取得上个客户阶段
	select @PrevStageID=StageID from OrderStage where ProcessID=@ProcessID and Sort=@Sort-1 and Status<>9

	update  OrderStage set Status=9 where StageID=@StageID and ProcessID=@ProcessID 

	update  OrderStage set Sort=Sort-1 where  ProcessID=@ProcessID and Sort>@Sort

	--更改客户阶段
	update Orders set StageID = @PrevStageID where ClientID=@ClientID and StageID=@StageID

	set @Err+=@@error
end


if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end