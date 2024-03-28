WITH m1 AS (
    SELECT 
        m.match_id as match_id,
        m.home_team as home_team,
        m.away_team as away_team,
        m.home_score as home_score,
        m.away_score as away_score,
        i.league as league,
        i.matchday as matchday,
        i.match_date as match_date,
        i.match_referee as match_referee
    FROM {{ref('stg_matches')}} AS m
    LEFT JOIN {{ref('stg_matches_info')}} AS i
    ON m.match_id = i.match_id
)
SELECT 
    m1.league as league,
    m1.home_team as team,
    m1.matchday,
    COUNT(CASE WHEN m2.home_score > m2.away_score THEN 1 ELSE NULL END) AS cumulative_wins,
    COUNT(CASE WHEN m2.home_score < m2.away_score THEN 1 ELSE NULL END) AS cumulative_losses,
    COUNT(CASE WHEN m2.home_score = m2.away_score THEN 1 ELSE NULL END) AS cumulative_draws,
    SUM(CASE WHEN m2.home_score > m2.away_score THEN 3 WHEN m2.home_score = m2.away_score THEN 1 ELSE 0 END) AS cumulative_points
FROM 
    m1
JOIN 
    m1 AS m2 ON m1.home_team = m2.home_team AND m2.matchday <= m1.matchday
GROUP BY 
    m1.home_team, 
    m1.matchday,
    m1.league
ORDER BY
    m1.matchday,
    m1.home_team