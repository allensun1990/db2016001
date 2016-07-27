Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateProcessCategory')
BEGIN
	DROP  Procedure  P_CreateProcessCategory
END

GO
/***********************************************************
过程名称： P_CreateProcessCategory
功能描述： 添加订单品类
参数说明：	 
编写日期： 2016/7/27
程序作者： Allen
调试记录： exec P_CreateProcessCategory 
************************************************************/
CREATE PROCEDURE [dbo].P_CreateProcessCategory
@CategoryID nvarchar(64),
@Name nvarchar(100),
@Remark nvarchar(4000)='',
@UserID nvarchar(64)=''
AS

begin tran


declare @Err int=0
 
insert into ProcessCategory(CategoryID,Name,Remark,Status,CreateUserID)
					 values(@CategoryID,@Name,@Remark,1,@UserID)


--打样-订单tab
insert into CategoryItems(ItemID, Name,   CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'制版工艺',@CategoryID,   1,    1,     12,   1,   '', @UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'面辅料',  @CategoryID,   1,    1,     11,   2,   '',@UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'加工成本',@CategoryID,   1,    1,     16,   3,   '',@UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'发货',    @CategoryID,   1,    1,     15,   4,   '',@UserID)

--打样-订单流程
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'面辅料',@CategoryID,              2,     1,      11,   1,   '',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'制版',@CategoryID,                2,     1,      12,   2,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'做样衣',@CategoryID,              2,     1,      0,    3,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'审版',@CategoryID,                2,     1,      0,    4,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'加工成本',@CategoryID,            2,     1,      16,   5,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'发货',@CategoryID,                2,     1,      15,   6,'',@UserID)

--打样-模块名称
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'面辅料',@CategoryID,              3,     1,      11,  1,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'制版',@CategoryID,                3,     1,      12,  2,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'做样衣',@CategoryID,              3,     1,      13,  3,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'审版',@CategoryID,                3,     1,      14,  4,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'加工成本',@CategoryID,            3,     1,      16,  5,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'发货',@CategoryID,                3,     1,      15,  6,'',@UserID)


--大货-订单tab
insert into CategoryItems(ItemID, Name,   CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'制版工艺',@CategoryID,   1,    2,     22,   1,   '', @UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'面辅料',  @CategoryID,   1,    2,     21,   2,   '',@UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'加工成本',@CategoryID,   1,    2,     26,   3,   '',@UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'裁片',    @CategoryID,   1,    2,     23,   4,   '',@UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'车缝',    @CategoryID,   1,    2,     24,   5,   '',@UserID)
insert into CategoryItems(ItemID,Name,    CategoryID,  Type,OrderType,Mark,Sort,Remark,CreateUserID)
				values(NEWID(),'发货',    @CategoryID,   1,    2,     25,   6,   '',@UserID)

--大货-订单流程
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'推码/工艺单',@CategoryID,         2,     2,      22,   1,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'面辅料',@CategoryID,              2,     2,      21,   2,   '',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'裁剪',@CategoryID,                2,     2,      23,   3,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'车缝',@CategoryID,                2,     2,      24,   4,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'品控',@CategoryID,                2,     2,      0,    5,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'发货',@CategoryID,                2,     2,      25,   6,'',@UserID)

--大货-模块名称
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'面辅料',@CategoryID,              3,     2,      21,  1,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'制版',@CategoryID,                3,     2,      22,  2,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'做样衣',@CategoryID,              3,     2,      23,  3,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'审版',@CategoryID,                3,     2,      24,  4,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'加工成本',@CategoryID,            3,     2,      26,  5,'',@UserID)
insert into CategoryItems(ItemID,Name,CategoryID,Type,OrderType,Mark,Sort,Remark,CreateUserID)
values(NEWID(),'发货',@CategoryID,                3,     2,      25,  6,'',@UserID)

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end