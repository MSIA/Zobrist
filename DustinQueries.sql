
SELECT min(click_date),max(click_date) FROM clickstream.log;

/*This query gets the total clicks per user*/
SELECT user_id, count(*) AS Clicks
FROM clickstream.log
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY Clicks DESC;

SELECT count(DISTINCT user_id)
FROM clickstream.log;





/*This query gets histogram of MaxClicksInDay per user*/
SELECT MaxClicksInDay ,count(user_)
FROM
(SELECT NAME_ AS user_, max(Clicks) AS maxClicks, CASE WHEN max(Clicks) = 1 THEN '1'
                                                      WHEN max(Clicks) = 2 THEN '2'
                                                      WHEN max(Clicks) BETWEEN 3 AND 5 THEN '3-5'
                                                      WHEN max(Clicks) BETWEEN 6 AND 10 THEN '6-10'
                                                      WHEN max(Clicks) BETWEEN 11 AND 100 THEN '11-100'
                                                      WHEN max(Clicks) BETWEEN 101 AND 1000 THEN '101-1000'
                                                      ELSE '1000+' END AS MaxClicksInDay
FROM

  (SELECT user_id AS NAME_,
    click_date AS DATE,
    count(*)   AS Clicks
  FROM clickstream.log
  WHERE user_id IS NOT NULL
  GROUP BY user_id, click_date
  ORDER BY Clicks DESC) AS table1


GROUP BY user_
ORDER BY maxClicks) AS table2

GROUP BY MaxClicksInDay
;

SELECT * FROM clickstream.log LIMIT 100;

SELECT count(*) FROM clickstream.log;






/*Get longest consecutive stretch (in days) that a user logged in*/
WITH MaxStretches AS (
    WITH StretchesByUsers AS (
      WITH groupedDatesbyUsers AS (
              SELECT  user_id,
                click_date,
          ((-ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY click_date))*'1 day'::interval  + click_date)::date As GroupingSet
        FROM    clickstream.log
        WHERE user_id IS NOT NULL
        GROUP BY click_date, user_id
        ORDER BY user_id, click_date)

        SELECT user_id, min(click_date) AS StartDate, max(click_date) AS EndDate, count(user_id) AS LargestStretch
        FROM groupedDatesbyUsers
        GROUP BY user_id, GroupingSet
        ORDER BY LargestStretch DESC)

    SELECT max(LargestStretch) AS BiggestStretch
    FROM StretchesByUsers
    GROUP BY user_id
    ORDER BY BiggestStretch DESC)

SELECT BiggestStretch, count(*)
FROM MaxStretches
GROUP BY BiggestStretch
ORDER BY BiggestStretch DESC
;



/*time btw clicks*/
WITH organized AS (
    SELECT user_id, click_date, click_time, job_id, ip, (click_date+click_time) AS TS,
           row_number() OVER (PARTITION BY user_id ORDER BY (click_date+click_time)) AS RN
    FROM clickstream.log
    WHERE user_id IS NOT NULL
)

SELECT B.user_id, B.click_date, B.click_time, B.job_id, B.ip, (A.TS - B.TS) AS TimeUntilNextClick
FROM organized AS A JOIN organized AS B ON (A.user_id=B.user_id AND A.RN=B.RN+1)
WHERE (A.TS-B.TS) IS NOT NULL
;

SELECT * FROM clickstream.click_time_btw;

GRANT ALL ON clickstream.user_day_clickstreak TO solivar, xwang, scarruthers, cwei WITH GRANT OPTION;






    WITH StretchesByUsers AS (
      WITH groupedDatesbyUsers AS (
              SELECT  user_id,
                click_date,
          ((-ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY click_date))*'1 day'::interval  + click_date)::date As GroupingSet
        FROM    clickstream.log
        WHERE user_id IS NOT NULL
        GROUP BY click_date, user_id
        ORDER BY user_id, click_date)

        SELECT user_id, min(click_date) AS StartDate, max(click_date) AS EndDate, count(user_id) AS LargestStretch
        FROM groupedDatesbyUsers
        GROUP BY user_id, GroupingSet
        ORDER BY LargestStretch DESC)

    SELECT user_id, max(LargestStretch) AS BiggestStretch
    FROM StretchesByUsers
    GROUP BY user_id
    ORDER BY BiggestStretch DESC;

SELECT count(*), CASE WHEN click_time_btw.timeuntilnextclick BETWEEN -1*'1 second'::INTERVAL AND 10*'1 second'::INTERVAL THEN '<10 sec'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 10.001*'1 second'::INTERVAL AND 30*'1 second'::INTERVAL THEN '10-30 sec'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 30.001*'1 second'::INTERVAL AND 60*'1 second'::INTERVAL THEN '30-60 sec'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 60.001*'1 second'::INTERVAL AND 120*'1 second'::INTERVAL THEN '1-2 min'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 120.001*'1 second'::INTERVAL AND 300*'1 second'::INTERVAL THEN '2-5 min'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 300.001*'1 second'::INTERVAL AND 600*'1 second'::INTERVAL THEN '5-10 min'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 600.001*'1 second'::INTERVAL AND 1200*'1 second'::INTERVAL THEN '10-20 min'
             WHEN click_time_btw.timeuntilnextclick BETWEEN 1200.001*'1 second'::INTERVAL AND 3600*'1 second'::INTERVAL THEN '20-60 min'
             ELSE '1000+' END AS Bin
FROM click_time_btw
GROUP BY Bin;








SELECT biggeststretch, count(*) FROM clickstream.user_day_clickstreak GROUP BY biggeststretch ORDER BY biggeststretch;

SELECT NAME_ AS user_, max(Clicks) AS maxClicks, CASE WHEN max(Clicks) = 1 THEN '1'
                                                      WHEN max(Clicks) = 2 THEN '2'
                                                      WHEN max(Clicks) BETWEEN 3 AND 5 THEN '3-5'
                                                      WHEN max(Clicks) BETWEEN 6 AND 10 THEN '6-10'
                                                      WHEN max(Clicks) BETWEEN 11 AND 100 THEN '11-100'
                                                      WHEN max(Clicks) BETWEEN 101 AND 1000 THEN '101-1000'
                                                      ELSE '1000+' END AS MaxClicksInDay
FROM

  (SELECT user_id AS NAME_,
    click_date AS DATE,
    count(*)   AS Clicks
  FROM clickstream.log
  WHERE user_id IS NOT NULL
  GROUP BY user_id, click_date
  ORDER BY Clicks DESC) AS table1


GROUP BY user_
ORDER BY maxClicks DESC;

SELECT * FROM clickstream.jobdescription LIMIT 10;
