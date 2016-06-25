
--大货单翻单批次
alter table Orders add TurnTimes int default 0
Update Orders set TurnTimes=0 where OrderType=1
Update Orders set TurnTimes=1 where OrderType=2

select o.OriginalID,o.OrderID,count(o1.AutoID) C into #Temp from  Orders o join Orders o1 on o.OriginalID=o1.OriginalID and o1.AutoID<o.AutoID
where o.OrderType=2 and o1.OrderType=2 and o.OriginalID<>'' group by o.OriginalID,o.OrderID 

UPDATE o set TurnTimes=TurnTimes+o1.C from Orders o join #Temp o1 on o.OrderID=o1.OrderID

drop table #Temp

Update o set TurnTimes=od.C from Orders o join (
select OriginalID,count(AutoID) C  from  Orders where OrderType=2 and OriginalID<>'' group by OriginalID) od on o.OrderID=od.OriginalID  