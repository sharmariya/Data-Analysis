use SupplyChain

--table view
select * from FreightRates
select * from OrderList
select * from PlantPorts
select * from ProductsPerPlant
select * from VmiCustomers
select * from WhCapacities
select * from WhCosts



--Top Customers by Total Unit Quantity Ordered

select Customer, 
sum([Unit quantity]) as UnitQuantity,
rank()over(order by sum([Unit quantity])  desc) as CustomerRank
from OrderList
group by Customer
order by 3


--Average Shipping Delay by Carrier

select Carrier, 
round(avg([Ship Late Day count]),3) as AvgLateDays
from OrderList
group by Carrier
order by 2 


--Rank Regions by Order Volume

select
[Origin Port] as OriginPort, 
[Destination Port] as DestinationPort,
sum([Unit quantity]) as OrderVol
from OrderList
group by [Origin Port] , [Destination Port]


--Underutilized Plants

select *, 
round(PERCENT_RANK()over(order by UtilizationRate),2) as PercentRank
from
(
select
[Plant Code] as PlantCode,
COUNT([Order ID]) as OrdersHandled,
[Daily Capacity ] as DailyCapacity,
round((COUNT([Order ID]) *1.0/ [Daily Capacity ]),3) as UtilizationRate
from OrderList o join WhCapacities c
on o.[Plant Code] =c.[Plant ID]
group by [Plant Code], [Daily Capacity ] 
--order by 3 desc
) cap


--Identify Top 10 Customers Contributing to Maximum Cost by Plant

;with costs as 
(select [Plant Code],
[Product ID],
round(sum(rate* [Unit quantity]),2) as cost,
RANK()over(partition by [Plant Code] order by round(sum(rate* [Unit quantity]),2)  desc) as ProdRank
from OrderList o join FreightRates f
on o.Carrier = f.Carrier
group by [Plant Code], [Product ID]
--order by 1
)
select *
from costs
where ProdRank <11


--Identify the Average Rate of Freight Mode for Each Route

select orig_port_cd as OriginPort, 
dest_port_cd as DestinationPort,
mode_dsc as FreightMode,
avg(rate) as AvgRate
from OrderList o join FreightRates f
on o.Carrier = f.Carrier
group by orig_port_cd , dest_port_cd,mode_dsc


--Detect Outliers in Freight Costs by Carrier

select Carrier,
rate as FreightRate,
AVG(rate)over(partition by Carrier) as AvgRate,
STDEV(rate)over(partition by Carrier) as StdDevRate,
CASE
When rate > AVG(rate)over(partition by Carrier) + 2*STDEV(rate)over(partition by Carrier) 
Then 'High Outlier'
When rate < AVG(rate)over(partition by Carrier) - 2*STDEV(rate)over(partition by Carrier) 
Then 'Low Outlier'
else 'Normal' 
end as OutlierStatus
from FreightRates


--Revenue by Route and Plant

select [Plant Code],
orig_port_cd as OriginPort, 
dest_port_cd as DestinationPort,
round(sum(rate*Weight),2) as TotalRevenue
from OrderList o join FreightRates f
on o.Carrier = f.Carrier
group by [Plant Code], orig_port_cd , dest_port_cd
order by 1,4 desc


--Detect Shipment Bottlenecks by Analyzing Late Shipments

select 
[Origin Port], 
[Destination Port],
count(case when [Ship Late Day count] >0 then 1 end) *100.0/count([Order ID]) as LateShipmentPercentage,
case
when count(case when [Ship Late Day count] >0 then 1 end)*100.0/count([Order ID]) > 50 then 'Critical'
when count(case when [Ship Late Day count] >0 then 1 end)*100.0/count([Order ID]) between 20 and 50 then 'Moderate'
else 'Low Risk'
end as RiskCategory
from OrderList
group by [Origin Port], [Destination Port]


--Overloaded and Underutilized Plants

select [Plant Code], 
round(avg(sum([Unit quantity]))over(partition by [Plant Code]),2) as AvgOrders,
[Daily Capacity ],
case 
when round(avg(sum([Unit quantity]))over(partition by [Plant Code]),2) >[Daily Capacity ]
then 'Overloaded'
when round(avg(sum([Unit quantity]))over(partition by [Plant Code]),2) <[Daily Capacity ]
then 'Underloaded'
else 
'Optimal'
end as UtilizationStatus
from OrderList o
join WhCapacities c on
o.[Plant Code]=c.[Plant ID]
group by [Plant Code],[Daily Capacity ]


--Fulfillment Lag Analysis

select [Order ID],
[Plant Code],
[Unit quantity],
[Daily Capacity ],
CEILING([Unit quantity]*1.0/[Daily Capacity ])-1 as FulfillmentLagDays
from OrderList o
join WhCapacities c
on o.[Plant Code]=c.[Plant ID]
where [Unit quantity]> [Daily Capacity ]
