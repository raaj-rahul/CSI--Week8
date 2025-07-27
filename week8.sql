DELIMITER //

CREATE PROCEDURE PopulateTimeDimension(IN input_date DATE)
BEGIN
    DECLARE year_start DATE;
    DECLARE year_end DATE;

    SET year_start = MAKEDATE(YEAR(input_date), 1);
    SET year_end = MAKEDATE(YEAR(input_date) + 1, 1) - INTERVAL 1 DAY;

    INSERT INTO TimeDimension (
        Date, CalendarDay, CalendarMonth, CalendarQuarter, CalendarYear,
        DayNameLong, DayNameShort, DayNumberOfWeek, DayNumberOfYear,
        DaySuffix, FiscalWeek, FiscalPeriod, FiscalQuarter, FiscalYear
    )
    SELECT
        d.Date,
        DAY(d.Date),
        MONTH(d.Date),
        QUARTER(d.Date),
        YEAR(d.Date),
        DAYNAME(d.Date),
        DATE_FORMAT(d.Date, '%a'),
        DAYOFWEEK(d.Date),
        DAYOFYEAR(d.Date),
        CASE
            WHEN DAY(d.Date) IN (11, 12, 13) THEN CONCAT(DAY(d.Date), 'th')
            WHEN RIGHT(DAY(d.Date), 1) = '1' THEN CONCAT(DAY(d.Date), 'st')
            WHEN RIGHT(DAY(d.Date), 1) = '2' THEN CONCAT(DAY(d.Date), 'nd')
            WHEN RIGHT(DAY(d.Date), 1) = '3' THEN CONCAT(DAY(d.Date), 'rd')
            ELSE CONCAT(DAY(d.Date), 'th')
        END,
        WEEK(d.Date),
        MONTH(d.Date),
        QUARTER(d.Date),
        YEAR(d.Date)
    FROM (
        SELECT DATE_ADD(year_start, INTERVAL seq DAY) AS Date
        FROM (
            SELECT a.N + b.N * 10 + c.N * 100 AS seq
            FROM 
                (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
                 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
                (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
                 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
                (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) c
        ) AS numbers
        WHERE DATE_ADD(year_start, INTERVAL seq DAY) <= year_end
    ) AS d;
END //

DELIMITER ;
