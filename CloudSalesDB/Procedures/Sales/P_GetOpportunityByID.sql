Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOpportunityByID')
BEGIN
	DROP  Procedure  P_GetOpportunityByID
END

GO
/***********************************************************
过程名称： P_GetOpportunityByID
功能描述： 获取客户机会详情
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_GetOpportunityByID 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOpportunityByID]
	@OpportunityID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
declare @CustomerID nvarchar(64),@Status int 

select @CustomerID=CustomerID,@Status=Status from Opportunity where OpportunityID=@OpportunityID and ClientID=@ClientID

select * from Opportunity where OpportunityID=@OpportunityID and ClientID=@ClientID

select * from Customer where CustomerID=@CustomerID and ClientID=@ClientID

select * from OpportunityProduct  where OpportunityID=@OpportunityID 

