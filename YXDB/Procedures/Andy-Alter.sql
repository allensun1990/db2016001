


CREATE TABLE [dbo].[OrderPriceRange]
(
[AutoID] [int] IDENTITY(1,1) identity(1,1),
[RangeID] [nvarchar](64) primary key,
[OrderID] [nvarchar](64),
[MinQuantity] [int] default 1,
[Price] [decimal](18, 3) default 0,
[Status] [int] default 1,
[ClientID] [nvarchar](64) NOT NULL,
[CreateTime] [datetime] default getdate(),
[CreateUserID] [nvarchar](64) NULL
) 








