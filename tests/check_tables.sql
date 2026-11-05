-- Verify that all expected tables exist in your db.
-- Once every cluster is merged, this should list 17 tables.
-- Right after running drop_all_tables.sql, it should list none.
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;