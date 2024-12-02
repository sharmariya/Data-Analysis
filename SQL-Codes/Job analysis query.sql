select Jobnummer, round(sum(income),2) as Net_Income,round(sum(cost),2) as Net_Cost, round(sum(Billability),2) as Net_Billable, round(sum(profitability),2) as Net_Profitablity
from [Job Analysis]
group by Jobnummer
order by 1



