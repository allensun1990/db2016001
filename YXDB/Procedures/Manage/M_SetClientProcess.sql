Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_SetClientProcess')
BEGIN
	DROP  Procedure  M_SetClientProcess
END

GO
/***********************************************************
过程名称： M_SetClientProcess
功能描述： 初始化品类流程
参数说明：	 
编写日期： 2016/5/20
程序作者： Allen
调试记录： exec M_SetClientProcess 
************************************************************/
CREATE PROCEDURE [dbo].[M_SetClientProcess]
@IDS nvarchar(4000),
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功
AS

begin tran

set @Result=0

declare @Err int=0,@ProcessIDDY nvarchar(64),@ProcessIDDH nvarchar(64),@CategoryID nvarchar(64),@sql nvarchar(4000),@AutoID int=1,@Name nvarchar(50)

--初始化状态
if not exists(select AutoID from Clients where GuideStep=1)
begin
	set @Result=1
	rollback tran
	return
end

create table #TempTable(ID int identity(1,1),Value nvarchar(4000))
set @sql='select col='''+ replace(@IDS,',',''' union all select ''')+''''
insert into #TempTable exec (@sql)

while exists(select ID from #TempTable where ID=@AutoID)
begin
	select @CategoryID=Value from #TempTable where ID=@AutoID
	if(LEN(@CategoryID)>0)
	begin
		if not exists(select AutoID from OrderCategory where CategoryID=@CategoryID and ClientID=@ClientID)
		begin
			Insert into OrderCategory(CategoryID,Layers,ClientID,PID) values(@CategoryID,1,@ClientID,'')
		end

		select @Name=Name from ProcessCategory where CategoryID=@CategoryID

		select @ProcessIDDY=NEWID(),@ProcessIDDH=NEWID()

		--打样流程
		Insert into OrderProcess(ProcessID,ProcessName,ProcessType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID,CategoryID)
		values(@ProcessIDDY,@Name+'打样流程',1,1,1,0,@UserID,@UserID,@ClientID,@CategoryID)

		insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
		select NEWID(),Name,@ProcessIDDY,1,1,11,'',@UserID,@UserID,@ClientID from CategoryItems 
		where CategoryID=@CategoryID and OrderType=1 and Type=2

		--大货流程
		Insert into OrderProcess(ProcessID,ProcessName,ProcessType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID,CategoryID)
		values(@ProcessIDDH,@Name+'大货流程',2,1,1,0,@UserID,@UserID,@ClientID,@CategoryID)

		insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
		select NEWID(),Name,@ProcessIDDH,Sort,1,Mark,'',@UserID,@UserID,@ClientID from CategoryItems 
		where CategoryID=@CategoryID and OrderType=2 and Type=2

	end
	set @AutoID+=1
end

set @Err+=@@error

IF EXISTS(select AutoID from UserAccounts where UserID=@UserID and AccountType=2)
begin
	Update Clients set GuideStep=0 where ClientID=@ClientID
end
else
begin
	Update Clients set GuideStep=3 where ClientID=@ClientID
end



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