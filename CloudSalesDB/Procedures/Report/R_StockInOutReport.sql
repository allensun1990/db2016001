 Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_StockInOutReport')
BEGIN
	DROP  Procedure  R_StockInOutReport
END

GO
/****** Object:  StoredProcedure [dbo].[R_StockInOutReport]    Script Date: 05/04/2016 14:38:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_StockInOutReport
功能描述： 查询产品库存明细报表
参数说明：	 
编写日期： 2016/7/26
程序作者： Michaux
调试记录：
************************************************************/
create  proc  R_StockInOutReport
@clientID varchar(50)='',
@beginTime varchar(50)='',
@endTime varchar(50)='',  
@keyWords varchar(500),
@pageSize int,
@pageIndex int, 
@totalCount int output,
@pageCount int output
 as
 begin 
 if(@beginTime<>'')
 begin
	set @beginTime= cast(dateadd(MONTH,3 ,GETDATE()) as varchar)
 end 
 if(@endTime<>'')
 begin 
	set @endTime=GETDATE()
 end
 else
 begin
	set @endTime=@endTime+' 23:59:59:999'
 end
 
 select @totalCount=count(1) from ProductDetail  where status<>9
 set @pageCount=CEILING(@totalCount * 1.0/@pageSize)

 select Mark,ProductID,ProductDetailID,SUM(Quantity) as Quantity into #InOut
 from ProductStream where CreateTime>=@beginTime and CreateTime <=@endTime and ClientID=@clientID
 group by Mark,ProductID,ProductDetailID
 
 select  *,b.Quantity as InQuantity,c.Quantity as OutQuantity ,
  (select top 1 case mark when 0 then SurplusQuantity+Quantity else SurplusQuantity-Quantity  end as QCQuantity
from  ProductStream where ProductDetailID=a.ProductDetailID and  CreateTime>=@beginTime and CreateTime <=@endTime and ClientID=@clientID order by CreateTime asc )as QCQuantity,
  (select top 1 case mark when 0 then SurplusQuantity+Quantity else SurplusQuantity-Quantity  end as JYQuantity
from  ProductStream where ProductDetailID=a.ProductDetailID and  CreateTime>=@beginTime and CreateTime <=@endTime and ClientID=@clientID order by CreateTime desc )as JYQuantity
 from ProductDetail a 
 left join (select * from  #InOut where  Mark=0 ) b  on a.ProductDetailID=b.ProductDetailID 
 left join (select * from  #InOut where  Mark=1 ) c on a.ProductDetailID=c.ProductDetailID 
 where a.status<>9
 
 
 drop table #InOut
  
 end