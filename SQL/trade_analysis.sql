-- India Trade Deficit & Commodity Prioritization Analytics
-- Data source: UN Comtrade
-- Coverage: India, World partner, 2020-2024, HS 2-digit commodities
-- Database: PostgreSQL

-- ============================================================
-- 01. DATA VALIDATION
-- ============================================================

-- Total records
SELECT COUNT(*) AS total_records
FROM india_trade_commodity_raw;

-- Records by year and trade flow
SELECT
    ref_year AS year,
    flow_desc AS trade_flow,
    COUNT(*) AS records
FROM india_trade_commodity_raw
GROUP BY ref_year, flow_desc
ORDER BY ref_year, flow_desc;


-- ============================================================
-- 02. ANNUAL TRADE SUMMARY
-- ============================================================

SELECT
    ref_year AS year,
    ROUND(
        SUM(primary_value) FILTER (WHERE flow_code = 'X')
        / 1000000000.0, 2
    ) AS exports_billion_usd,
    ROUND(
        SUM(primary_value) FILTER (WHERE flow_code = 'M')
        / 1000000000.0, 2
    ) AS imports_billion_usd,
    ROUND(
        (
            SUM(primary_value) FILTER (WHERE flow_code = 'X')
            -
            SUM(primary_value) FILTER (WHERE flow_code = 'M')
        ) / 1000000000.0, 2
    ) AS trade_balance_billion_usd
FROM india_trade_commodity_raw
GROUP BY ref_year
ORDER BY ref_year;


-- ============================================================
-- 03. IMPORT AND EXPORT YEAR-OVER-YEAR GROWTH
-- ============================================================

WITH annual_trade AS (
    SELECT
        ref_year AS year,
        SUM(primary_value) FILTER (WHERE flow_code = 'M')
            / 1000000000.0 AS imports,
        SUM(primary_value) FILTER (WHERE flow_code = 'X')
            / 1000000000.0 AS exports
    FROM india_trade_commodity_raw
    GROUP BY ref_year
),
growth AS (
    SELECT
        year,
        imports,
        exports,
        LAG(imports) OVER (ORDER BY year) AS previous_imports,
        LAG(exports) OVER (ORDER BY year) AS previous_exports
    FROM annual_trade
)
SELECT
    year,
    ROUND(imports, 2) AS imports_billion_usd,
    ROUND(exports, 2) AS exports_billion_usd,
    ROUND(
        ((imports - previous_imports) / NULLIF(previous_imports, 0)) * 100,
        2
    ) AS import_yoy_pct,
    ROUND(
        ((exports - previous_exports) / NULLIF(previous_exports, 0)) * 100,
        2
    ) AS export_yoy_pct
FROM growth
ORDER BY year;


-- ============================================================
-- 04. 2024 TOP TRADE-DEFICIT COMMODITY CATEGORIES
-- ============================================================

SELECT
    cmd_code AS commodity_code,
    LEFT(cmd_desc, 55) AS commodity,
    ROUND(
        SUM(primary_value) FILTER (WHERE flow_code = 'M')
        / 1000000000.0, 2
    ) AS imports_billion_usd,
    ROUND(
        SUM(primary_value) FILTER (WHERE flow_code = 'X')
        / 1000000000.0, 2
    ) AS exports_billion_usd,
    ROUND(
        (
            SUM(primary_value) FILTER (WHERE flow_code = 'M')
            -
            SUM(primary_value) FILTER (WHERE flow_code = 'X')
        ) / 1000000000.0, 2
    ) AS trade_deficit_billion_usd
FROM india_trade_commodity_raw
WHERE ref_year = 2024
GROUP BY cmd_code, cmd_desc
ORDER BY trade_deficit_billion_usd DESC
LIMIT 10;


-- ============================================================
-- 05. CHANGE IN DEFICIT FOR THE TOP 5 2024 CATEGORIES
-- ============================================================

WITH top_2024 AS (
    SELECT
        cmd_code
    FROM india_trade_commodity_raw
    WHERE ref_year = 2024
    GROUP BY cmd_code
    ORDER BY
        SUM(primary_value) FILTER (WHERE flow_code = 'M')
        -
        SUM(primary_value) FILTER (WHERE flow_code = 'X')
        DESC
    LIMIT 5
)
SELECT
    cmd_code AS commodity_code,
    LEFT(MAX(cmd_desc), 45) AS commodity,
    ROUND((
        SUM(primary_value) FILTER (
            WHERE ref_year = 2020 AND flow_code = 'M'
        )
        -
        SUM(primary_value) FILTER (
            WHERE ref_year = 2020 AND flow_code = 'X'
        )
    ) / 1000000000.0, 2) AS deficit_2020_billion,
    ROUND((
        SUM(primary_value) FILTER (
            WHERE ref_year = 2024 AND flow_code = 'M'
        )
        -
        SUM(primary_value) FILTER (
            WHERE ref_year = 2024 AND flow_code = 'X'
        )
    ) / 1000000000.0, 2) AS deficit_2024_billion,
    ROUND((
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'X'
            )
        )
        -
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'X'
            )
        )
    ) / 1000000000.0, 2) AS deficit_change_billion
FROM india_trade_commodity_raw
WHERE cmd_code IN (SELECT cmd_code FROM top_2024)
GROUP BY cmd_code
ORDER BY deficit_change_billion DESC;


-- ============================================================
-- 06. TOTAL DEFICIT DETERIORATION AND TOP 5 CONTRIBUTION
-- ============================================================

WITH commodity_change AS (
    SELECT
        cmd_code,
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'X'
            )
        )
        -
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'X'
            )
        ) AS deficit_change
    FROM india_trade_commodity_raw
    GROUP BY cmd_code
),
total_change AS (
    SELECT
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'X'
            )
        )
        -
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'X'
            )
        ) AS total_deficit_change
    FROM india_trade_commodity_raw
)
SELECT
    ROUND(total_change.total_deficit_change / 1000000000.0, 2)
        AS total_deficit_change_billion,
    ROUND(
        SUM(commodity_change.deficit_change)
        FILTER (
            WHERE commodity_change.cmd_code IN ('27','71','85','84','15')
        ) / 1000000000.0,
        2
    ) AS top5_deficit_change_billion,
    ROUND(
        (
            SUM(commodity_change.deficit_change)
            FILTER (
                WHERE commodity_change.cmd_code IN ('27','71','85','84','15')
            )
            / total_change.total_deficit_change
        ) * 100,
        2
    ) AS top5_contribution_pct
FROM commodity_change
CROSS JOIN total_change
GROUP BY total_change.total_deficit_change;


-- ============================================================
-- 07. 10% IMPORT-SUBSTITUTION SCENARIO FOR TOP 5
-- ============================================================

WITH top5 AS (
    SELECT
        cmd_code,
        MAX(cmd_desc) AS commodity,
        SUM(primary_value) FILTER (
            WHERE ref_year = 2024 AND flow_code = 'M'
        ) AS imports_2024
    FROM india_trade_commodity_raw
    WHERE cmd_code IN ('27','71','85','84','15')
    GROUP BY cmd_code
)
SELECT
    cmd_code AS commodity_code,
    LEFT(commodity, 45) AS commodity,
    ROUND(imports_2024 / 1000000000.0, 2)
        AS imports_2024_billion,
    ROUND(imports_2024 * 0.10 / 1000000000.0, 2)
        AS modeled_10pct_opportunity_billion
FROM top5

UNION ALL

SELECT
    'TOTAL',
    'Top 5 commodities',
    ROUND(SUM(imports_2024) / 1000000000.0, 2),
    ROUND(SUM(imports_2024) * 0.10 / 1000000000.0, 2)
FROM top5;


-- ============================================================
-- 08. TRADE PRIORITY SCORE
-- ============================================================
-- Score weights:
--   40% = deficit deterioration
--   35% = 2024 import share
--   25% = import growth
--
-- Scores are normalized to 0-100 across the 97 HS-2 categories.

WITH commodity_metrics AS (
    SELECT
        cmd_code,
        MAX(cmd_desc) AS commodity,

        SUM(primary_value) FILTER (
            WHERE ref_year = 2020 AND flow_code = 'M'
        ) AS imports_2020,

        SUM(primary_value) FILTER (
            WHERE ref_year = 2024 AND flow_code = 'M'
        ) AS imports_2024,

        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2024 AND flow_code = 'X'
            )
        )
        -
        (
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'M'
            )
            -
            SUM(primary_value) FILTER (
                WHERE ref_year = 2020 AND flow_code = 'X'
            )
        ) AS deficit_change

    FROM india_trade_commodity_raw
    GROUP BY cmd_code
),
metrics AS (
    SELECT
        *,
        imports_2024 / NULLIF(SUM(imports_2024) OVER (), 0)
            AS import_share,
        (
            (imports_2024 / NULLIF(imports_2020, 0)) - 1
        ) * 100 AS import_growth_pct
    FROM commodity_metrics
),
normalized AS (
    SELECT
        *,
        (
            (deficit_change - MIN(deficit_change) OVER ())
            /
            NULLIF(
                MAX(deficit_change) OVER ()
                - MIN(deficit_change) OVER (),
                0
            )
        ) * 100 AS deficit_score,

        (
            import_share / NULLIF(MAX(import_share) OVER (), 0)
        ) * 100 AS import_share_score,

        (
            (import_growth_pct - MIN(import_growth_pct) OVER ())
            /
            NULLIF(
                MAX(import_growth_pct) OVER ()
                - MIN(import_growth_pct) OVER (),
                0
            )
        ) * 100 AS growth_score

    FROM metrics
)
SELECT
    cmd_code AS commodity_code,
    LEFT(commodity, 55) AS commodity,
    ROUND(imports_2024 / 1000000000.0, 2)
        AS imports_2024_billion,
    ROUND(deficit_change / 1000000000.0, 2)
        AS deficit_change_billion,
    ROUND(import_growth_pct, 2)
        AS import_growth_pct,
    ROUND(
        deficit_score * 0.40
        + import_share_score * 0.35
        + growth_score * 0.25,
        2
    ) AS priority_score
FROM normalized
ORDER BY priority_score DESC;


-- ============================================================
-- 09. EXPORT FINAL PRIORITY DATASET FOR POWER BI
-- ============================================================
-- Run from psql. Change the output path if required.
--
-- \copy (
--   <use the priority-score SELECT from section 08>
-- ) TO '/path/to/trade_priority_analysis.csv'
-- WITH (FORMAT CSV, HEADER TRUE);
