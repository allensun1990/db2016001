Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetUserSewnProcessReport')
BEGIN
	DROP  Procedure  R_GetUserSewnProcessReport
END

GO
/***********************************************************
过程名称： R_GetUserSewnProcessReport
功能描述： 获取员工工序统计（裁片-车缝）
参数说明：	 
编写日期： 2016/8/27
程序作者： Allen
调试记录： exec R_GetUserSewnProcessReport '2016-1-1','2018-1-1','','','5b2f9fdd-d044-4d6a-9c41-8597fd2faddd'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserSewnProcessReport]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@ClientID nvarchar(64)
AS

select g.OwnerID,g.ProcessID,tp.Name ProcessName,sum(gd.Quantity) Quantity,sum(gd.ReturnQuantity) ReturnQuantity,sum(oc.Price*gd.Quantity) Price,sum(oc.Price*gd.ReturnQuantity) ReturnPrice from GoodsDoc g 
join GoodsDocDetail gd on g.DocID=gd.DocID 
join OrderCosts oc on g.OrderID=oc.OrderID and oc.ProcessID=g.ProcessID
join TaskProcess tp on g.ProcessID=tp.ProcessID
where g.ClientID=@ClientID and g.DocType=11 and g.ProcessID is not null and g.ProcessID!='' and g.CreateTime between @BeginTime and @EndTime
group by g.OwnerID,g.ProcessID,tp.Name
having(sum(gd.Quantity)>0)
order by g.OwnerID,g.ProcessID

 



 

