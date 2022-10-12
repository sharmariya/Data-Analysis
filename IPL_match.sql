USE Projects;
--best bowler every season
SELECT d.*,m.*
into #data_merge
FROM deliveries$ d
INNER JOIN matches$ m
ON d.match_id=m.id

SELECT * FROM #data_merge
ORDER BY match_id,inning
--top 5 bowler every season
SELECT * FROM 
(SELECT season,bowler,COUNT(bowler) as wickets,
ROW_NUMBER() over (partition by season order by season,COUNT(bowler) desc) as standing
FROM #data_merge
WHERE player_dismissed is not null and (dismissal_kind <> 'run out') 
GROUP BY season,bowler) s
WHERE s.standing<=5
ORDER BY season,standing


-- best bowler every season
SELECT * FROM 
(SELECT season,bowler,COUNT(bowler) as wickets,
ROW_NUMBER() over (partition by season order by season,COUNT(bowler) desc) as standing
FROM #data_merge
WHERE player_dismissed is not null and (dismissal_kind <> 'run out') 
GROUP BY season,bowler) s
WHERE s.standing=1
ORDER BY season,standing


-- TOP  5 batsman every season
SELECT * FROM 
(SELECT season,batsman,SUM(total_runs) as runs,
ROW_NUMBER() over (partition by season order by season,SUM(total_runs) desc) as standing
FROM #data_merge
WHERE extra_runs=0 
GROUP BY season,batsman) s
WHERE s.standing<=5
ORDER BY season,standing


-- BEST BATSMAN EVERY SEASON
SELECT * FROM 
(SELECT season,batsman,SUM(total_runs) as runs,
ROW_NUMBER() over (partition by season order by season,SUM(total_runs) desc) as standing
FROM #data_merge
WHERE extra_runs=0 
GROUP BY season,batsman) s
WHERE s.standing=1
ORDER BY season,standing


-- FIRST AND SECOND INNING
SELECT * 
into #first_inning1
FROM
(
SELECT season,match_id,inning,SUM(total_runs) as score
FROM #data_merge
GROUP BY season,match_id,inning) d
WHERE inning=1
ORDER BY CAST(match_id as int),inning

SELECT * 
into #second_inning2
FROM
(
SELECT season,match_id,inning,SUM(total_runs) as score
FROM #data_merge
GROUP BY season,match_id,inning) d
WHERE inning=2
ORDER BY CAST(match_id as int),inning

SELECT s.season,s.match_id,f.score as first_innings,s.score as second_inning
FROM #first_inning1 f
inner join #second_inning2 s
on s.match_id=f.match_id
ORDER BY s.season,CAST(s.match_id as int)


-- TOSS IMPACT ON MATCH
SELECT season,count(match_id) as total_match,SUM(toss) toss_winner_wins
FROM
(SELECT * ,
(CASE
WHEN toss_winner=winner THEN 1
ELSE 0
END) toss
FROM
(SELECT match_id,season,toss_winner,winner
FROM #data_merge
GROUP BY match_id,season,toss_winner,winner) s)ss
GROUP BY season
ORDER BY CAST(season as int)