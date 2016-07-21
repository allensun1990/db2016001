Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateAttrValueSort')
BEGIN
	DROP  Procedure  P_UpdateAttrValueSort
END

GO
/***********************************************************
过程名称： P_UpdateAttrValueSort
功能描述： 编辑产品属性值排序
参数说明：	 
编写日期： 2016/3/23
程序作者： MU
调试记录： exec P_UpdateAttrValueSort 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateAttrValueSort]
@AttrID nvarchar(64),
@ValueID nvarchar(64),
@ValueName nvarchar(100),
@Sort int
AS

begin tran

declare @Err int, @MaxSort int=0 ,@OriginalSort int=0
set @Err=0

--select @OriginalSort=Sort from AttrValue where ValueID=@ValueID
--select @MaxSort=max(Sort) from AttrValue where AttrID=@AttrID and Status<>9
--if(@Sort>@MaxSort)
--begin
--	set @Sort=@MaxSort
--end

--if(@OriginalSort=@Sort)
--begin
--	Update AttrValue set Sort=@Sort,ValueName=@ValueName where AttrID=@AttrID and ValueID=@ValueID
--	commit tran
--	return
--end
--if(@Sort > @OriginalSort)
--begin
--	update AttrValue set Sort=Sort-1
--	where AttrID=@AttrID and Sort<=@Sort and sort>=@OriginalSort
--	set @Err+=@@error
--end
--else
--begin
--	update AttrValue set Sort=Sort+1
--	where AttrID=@AttrID and Sort>=@Sort and Sort<=@OriginalSort
--	set @Err+=@@error
--end

Update AttrValue set Sort=@Sort,ValueName=@ValueName where AttrID=@AttrID and ValueID=@ValueID
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end