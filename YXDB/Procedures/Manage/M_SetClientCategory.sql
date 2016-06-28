Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_SetClientCategory')
BEGIN
	DROP  Procedure  M_SetClientCategory
END

GO
/***********************************************************
过程名称： M_SetClientCategory
功能描述： 初始化流程
参数说明：	 
编写日期： 2016/5/20
程序作者： Allen
调试记录： exec M_SetClientCategory 
************************************************************/
CREATE PROCEDURE [dbo].[M_SetClientCategory]
@IDS nvarchar(4000),
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功
AS

begin tran

set @Result=0

declare @Err int=0,@CategoryID nvarchar(64),@sql nvarchar(4000),@AutoID int=1

--初始化状态
if not exists(select AutoID from Clients where GuideStep=2)
begin
	set @Result=1
	rollback tran
	return
end

set @Err+=@@error

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
			Insert into OrderCategory(CategoryID,Layers,ClientID,PID)
			select CategoryID,Layers,@ClientID,PID from Category where CategoryID=@CategoryID
		end
	end
	set @AutoID+=1
end

Update Clients set GuideStep=3 where ClientID=@ClientID

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