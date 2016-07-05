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
@Title nvarchar(200),
@Remark nvarchar(200),
@Icon nvarchar(200),
@TaskID nvarchar(64),
@OrderID nvarchar(64),
@Type nvarchar(64),
@UserID nvarchar(64),
@AgentID nvarchar(64)
as
	declare @OrderType int=1
	declare @OriginalID nvarchar(64)=''
	declare @PlateID nvarchar(64)=''
	set @PlateID=NEWID()

	select @OrderType=OrderType,@OriginalID=OriginalID from Orders where OrderID=@OrderID

	begin tran
	declare @Err int=0
	if(@OrderType=2)
	begin
		set @OrderID=@OriginalID
	end

	insert into  PlateMaking(PlateID,Title,Remark,Icon,TaskID,OrderID,Type,CreateUserID,AgentID,CreateTime) 
			values(@PlateID,@Title,@Remark,@Icon,@TaskID,@OrderID,@Type,@UserID,@AgentID,getdate())
			set @Err+=@@ERROR

	insert into  PlateMaking(PlateID,Title,Remark,Icon,TaskID,OrderID,Type,CreateUserID,AgentID,CreateTime,OriginalID,OriginalPlateID) 
		select NEWID(),@Title,@Remark,@Icon,@TaskID,OrderID,@Type,@UserID,@AgentID,getdate(),@OrderID,@PlateID from Orders
		where OrderType=2 and OriginalID=@OrderID and OrderStatus = 1
		set @Err+=@@ERROR

	if(@Err>0)
	begin
		rollback tran
	end 
	else
	begin
		commit tran
	end

		 





