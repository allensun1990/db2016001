
Create  table OtherSyncTaskRecord(
AutoID int identity(1,1),
OrderID nvarchar(64), --本地单据ID 
OtherSysID nvarchar(64), --外部单据ID
Type int default(1),--类型 1 入库单
Status int default(0),--0未处理 1已处理 2报错
SyncTime datetime ,
ErrorMsg text, --错误信息
Content nvarchar(2000), --参数内容
Remark nvarchar(300),--备注
ClientID nvarchar(64),--工厂ID
CreateTime datetime default(getdate()),
CreateUserID nvarchar(64),
UpdateTime datetime,
Operater nvarchar(64)--操作人
)

GO

P_GetOrdersByYXCode