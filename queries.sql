-- ============================================================================
-- 1A. Daily Active Users (DAU) by Day (for Before vs. After Feature Change)
-- ============================================================================
SELECT
  DATE(login_timestamp, 'unixepoch') AS login_date,
  COUNT(DISTINCT user_id) AS daily_active_users
FROM login_history
GROUP BY DATE(login_timestamp, 'unixepoch')
ORDER BY login_date ASC;

-- Optional: Daily Active Users bucketed into Pre-Launch vs. Post-Launch
-- Replace 'YYYY-MM-DD' with the feature launch date.
SELECT
  DATE(login_timestamp, 'unixepoch') AS login_date,
  CASE
    WHEN DATE(login_timestamp, 'unixepoch') < '2026-11-17' THEN 'Before Feature'
    ELSE 'After Feature'
  END AS period,
  COUNT(DISTINCT user_id) AS daily_active_users
FROM login_history
GROUP BY DATE(login_timestamp, 'unixepoch'), period
ORDER BY login_date ASC;

-- Optional: Average DAU before vs. after feature change
SELECT
  CASE
    WHEN DATE(login_timestamp, 'unixepoch') < '2026-11-17' THEN 'Before Feature'
    ELSE 'After Feature'
  END AS period,
  ROUND(AVG(dau), 2) AS avg_daily_active_users
FROM (
  SELECT
    DATE(login_timestamp, 'unixepoch') AS login_date,
    COUNT(DISTINCT user_id) AS dau
  FROM login_history
  GROUP BY DATE(login_timestamp, 'unixepoch')
) daily_counts
GROUP BY period;

-- ============================================================================
-- 2. Number of Status Changes by Card (Overall & Daily Breakdown)
-- ============================================================================
-- Total status changes per card
SELECT
  c.id AS card_id,
  c.name AS card_name,
  c.status AS current_status,
  COUNT(h.id) AS status_change_count
FROM card c
LEFT JOIN card_change_history h
  ON c.id = h.cardId
 AND h.oldStatus IS NOT h.newStatus
GROUP BY c.id, c.name, c.status
ORDER BY status_change_count DESC, c.id ASC;

-- Daily status changes per card (useful for a stacked/grouped time-series chart)
SELECT
  DATE(h.timestamp, 'unixepoch') AS change_date,
  c.id AS card_id,
  c.name AS card_name,
  COUNT(h.id) AS daily_status_changes
FROM card_change_history h
JOIN card c
  ON c.id = h.cardId
WHERE h.oldStatus IS NOT h.newStatus
GROUP BY DATE(h.timestamp, 'unixepoch'), c.id, c.name
ORDER BY change_date ASC, daily_status_changes DESC;
