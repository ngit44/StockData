Select * from [SP 500 Stock Prices 2014-2017]

-- Calculate Daily Price Range-Find the daily price range (difference between High and Low) for each stock.
SELECT 
    symbol,
	date,
    (high - low) AS DailyRange
FROM [SP 500 Stock Prices 2014-2017]
ORDER BY Symbol, date;

-- Monthly Average Closing Prices-Compute the average closing price for each stock grouped by month and year.
SELECT 
    symbol,
    YEAR(date) AS Year,
    MONTH(date) AS Month,
    ROUND(AVG([Close]), 4) AS AvgClose
FROM [SP 500 Stock Prices 2014-2017]
GROUP BY symbol, YEAR(date), MONTH(date)
ORDER BY symbol, Year, Month;

-- Identify Volatile Stocks-List the top 3 most volatile stocks (highest average daily range) over the entire dataset
WITH DailyRanges AS (
    SELECT 
        Symbol,
        (High - Low) AS DailyRange
    FROM [SP 500 Stock Prices 2014-2017]
),
AverageVolatility AS (
    SELECT 
        Symbol,
        AVG(DailyRange) AS AvgDailyRange
    FROM DailyRanges
    GROUP BY Symbol
)
SELECT 
    Symbol,
    ROUND(AvgDailyRange, 2) AS AvgDailyRange
FROM AverageVolatility
ORDER BY AvgDailyRange DESC;


-- Identify Days with the Highest Volume-List the top 5 trading days with the highest volume for each stock.
WITH RankedVolumes AS (
    SELECT 
        Symbol,
        Date,
        Volume,
        RANK() OVER (PARTITION BY Symbol ORDER BY Volume DESC) AS Rank
    FROM [SP 500 Stock Prices 2014-2017]
)
SELECT 
    Symbol,
    Date,
    Volume
FROM RankedVolumes
WHERE Rank <= 5
ORDER BY Symbol, Rank;

--Daily Percentage Change in Stock Prices-Calculate the percentage change in the closing price for each stock compared to the previous day.
WITH PriceChanges AS (
    SELECT 
        Symbol,
        date,
        [close] AS CurrentClose,
        LAG([close]) OVER (PARTITION BY Symbol ORDER BY Date) AS PreviousClose
    FROM [SP 500 Stock Prices 2014-2017]
)
SELECT 
    Symbol,
    Date,
    ROUND(((CurrentClose - PreviousClose) / PreviousClose) * 100, 2) AS PercentChange
FROM PriceChanges
WHERE PreviousClose IS NOT NULL
ORDER BY Symbol, Date;



--Moving Average of Closing Prices-Compute a 5-day moving average for the closing prices of each stock.
SELECT 
    Symbol,
    Date,
    [Close],
    AVG([Close]) OVER (
        PARTITION BY Symbol 
        ORDER BY Date 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS MovingAvg_5Day
FROM [SP 500 Stock Prices 2014-2017]
ORDER BY Symbol, Date;





-- Find Stocks with Consistent Growth Over a Week-Identify stocks that showed a daily price increase for five consecutive days.
WITH PriceComparison AS (
    SELECT 
        Symbol,
        Date,
        [Close],
        LAG([Close]) OVER (PARTITION BY Symbol ORDER BY Date) AS PreviousClose
    FROM [SP 500 Stock Prices 2014-2017]
),
GrowthStreak AS (
    SELECT 
        Symbol,
        Date,
        CASE 
            WHEN [Close] > PreviousClose THEN 1
            ELSE 0
        END AS Growth
    FROM PriceComparison
    WHERE PreviousClose IS NOT NULL
),
StreakCounter AS (
    SELECT 
        Symbol,
        Date,
        SUM(Growth) OVER (
            PARTITION BY Symbol 
            ORDER BY Date 
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS GrowthStreak
    FROM GrowthStreak
)
SELECT DISTINCT Symbol
FROM StreakCounter
WHERE GrowthStreak = 5;


