CREATE DATABASE CRICKETDATA;
USE CRICKETDATA;
SELECT * FROM asiacup;
SELECT * FROM batsman_data_odi;
SELECT * FROM bowler_data_odi;
SELECT * FROM Player_Name;
SELECT * FROM batsman_data_t20i;
SELECT * FROM bowler_data_t20i;
SELECT * FROM wicketkeeper_data_odi;
SELECT * FROM wicketkeeper_data_t20i;
SELECT * FROM champion2; 

-- Joins and Temporary Tables

-- 1. All Rounders in ODI and T20

-- ODI: 

SELECT B.player_name_btodi as Player_name, B.Player_ID, B.Country_Btodi as Country, B.Played_Btodi AS Batting_MAtches_Played , B.Runs_Btodi as Runs,
       BW.Time_Period_Bodi as Time_Period, BW.Best_Figure_Bodi as Best_Figure, BW.Played_Bodi as Bowling_Matches_Played, BW.Wickets_Bodi as Wickets
INTO ODI_ALL_ROUNDERS
FROM batsman_data_odi B
JOIN Player_Name P ON B.Player_ID = P.Player_ID
JOIN bowler_data_odi BW ON P.Player_ID = BW.player_ID;

-- ODI ALL ROUNDERS TEMP TABLE
SELECT * FROM ODI_ALL_ROUNDERS;

-- T20:

SELECT a.player_name_btt20 as Player_name, a.Player_ID, a.Country_Btt20 as Country, a.Played_Btt20 AS Batting_Matches_Played , a.Runs_Btt20 as Runs,
       BW.Time_Period_Bt20 as Time_Period, BW.Best_Figure_Bt20 as Best_Figure, BW.Played_Bt20 as Bowling_Matches_Played, BW.Wickets_Bt20 as Wickets
INTO T20_ALL_ROUNDERS
FROM dbo.batsman_data_t20i a
JOIN dbo.Player_Name p ON a.Player_ID = p.Player_ID
JOIN dbo.bowler_data_t20i bw ON p.Player_ID = bw.Player_ID

--T20 ALL ROUNDERS TEMP TABLE
SELECT * FROM T20_ALL_ROUNDERS

-- 2. Most Valuable Players (MVP) in Championships

-- Table with players of the match and players of the series

SELECT a.Championship_ID, a.Year, a.Format, a.Player_Of_The_Match, a.Match_ID, C.Host, C.Player_Of_The_Series_C, C.Champion, C.Runner_Up
INTO MVP
FROM asiacup a
JOIN Champion2 C ON A.Championship_ID = C.championship_ID
GROUP BY a.Player_Of_The_Match, a.Championship_ID, a.Year, a.Format, a.Match_ID, C.Host, C.Player_Of_The_Series_C, C.Champion, C.Runner_Up;

-- Example of query (Number of times each player won player of the match)

SELECT Player_Of_The_Match, COUNT(Player_Of_The_Match) FROM MVP
GROUP BY Player_Of_The_Match

-- 3. Best Performance of each player across formats

WITH PlayerPerformance AS (
    SELECT
        C.Player_ID,
        C.Player_of_the_series_C AS Player_Name,
        'Batsman' AS Role,
        'ODI' AS Format,
        B.matches_Btodi AS Matches,
        B.Runs_Btodi AS PerformanceMetric
    FROM
        Champion2 C
    LEFT JOIN
        Batsman_data_ODI B ON C.Player_ID = B.player_ID
    UNION ALL
    SELECT
        C.Player_ID,
        C.Player_of_the_series_C AS Player_Name,
        'Bowler' AS Role,
        'ODI' AS Format,
        BW.Wickets_Bodi AS Matches,
        BW.Wickets_Bodi AS PerformanceMetric
    FROM
        Champion2 C
    LEFT JOIN
        bowler_data_odi BW ON C.Player_ID = BW.player_ID
    UNION ALL
    SELECT
        C.Player_ID,
        C.Player_of_the_series_C AS Player_Name,
        'Wicketkeeper' AS Role,
        'ODI' AS Format,
        WK.dismissals_Wodi AS Matches,
        WK.dismissals_Wodi AS PerformanceMetric
    FROM
        champion2 C
    LEFT JOIN
        wicketkeeper_data_odi WK ON C.Player_ID = WK.Player_ID
    UNION ALL
    SELECT
        C.Player_ID,
        C.Player_of_the_series_C AS Player_Name,
        'Batsman' AS Role,
        'T20' AS Format,
        BT.matches_Btt20 AS Matches,
        BT.Runs_Btt20 AS PerformanceMetric
    FROM
        champion2 C
    LEFT JOIN
        batsman_data_t20i BT ON C.Player_ID = BT.player_ID
    UNION ALL
    SELECT
        C.Player_ID,
        C.Player_of_the_series_C AS Player_Name,
        'Bowler' AS Role,
        'T20' AS Format,
        BBT.Wickets_Bt20 AS Matches,
        BBT.Wickets_Bt20 AS PerformanceMetric
    FROM
        Champion2 C
    LEFT JOIN
        bowler_data_t20i BBT ON C.Player_ID = BBT.player_ID)
SELECT
    Player_Name,
    Role,
    Format,
    MAX(PerformanceMetric) AS Best_Performance
INTO PlayerPerformanceTable
FROM
    PlayerPerformance
GROUP BY
    Player_Name,
    Role,
    Format;

-- Temp table for player performance

SELECT * FROM PlayerPerformanceTable;

-- Example of query: 

SELECT *
FROM PlayerPerformanceTable
WHERE Player_Name = 'A Ranatunga'


-- 4. Join: relationship between team that hosted a tournament and their wins

SELECT
    AC.year,
    AC.format,
    CH.Host AS Host_Team,
    CH.Champion AS Winning_Team
INTO HOST_TEAMS
FROM
    asiacup AC
INNER JOIN
    champion2 CH ON AC.Championship_ID = CH.championship_ID
	GROUP BY AC.year,
    AC.format, CH.Host, CH.Champion;

-- Example: cheecking all tournaments hosted by UAE: 

SELECT * FROM HOST_TEAMS WHERE Host_Team = 'UAE'

-- KPIs:
-- List of tables: All Rounders, MVP, Player Performance across formats, teams who hosted tournaments and who won those tournaments


-- 1. KPI 1: Runs Per Match for All-Rounders (Average):

SELECT Player_name, Runs / Batting_MAtches_Played AS Run_Average
FROM ODI_ALL_ROUNDERS;

-- 2. KPI 2: Number of Player of the Match Awards per player

SELECT Player_of_the_Match, COUNT(*) AS POTM_Awards
FROM MVP
GROUP BY Player_of_the_Match
ORDER BY POTM_Awards DESC 

-- 3. KPI 3: Player Average Across Formats

SELECT AVG(Best_Performance) FROM PlayerPerformanceTable WHERE Player_Name = 'Shakib Al Hasan' 

