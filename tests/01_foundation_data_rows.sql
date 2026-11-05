-- Verify row counts for the Foundation cluster against the expected seed data.
-- Every row should show Result = 'OK'. A 'CHECK' means the seed file didn't
-- fully run, or ran twice (in which case drop, recreate, and reseed).
SELECT t.TableName, t.Expected, t.Actual,
       CASE WHEN t.Actual = t.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
              SELECT 'Business'            AS TableName, 10 AS Expected, (SELECT COUNT(*) FROM dbo.Business)            AS Actual
    UNION ALL SELECT 'Location',                         13,             (SELECT COUNT(*) FROM dbo.Location)
    UNION ALL SELECT 'CancellationPolicy',               13,             (SELECT COUNT(*) FROM dbo.CancellationPolicy)
    UNION ALL SELECT 'LocationSocialMedia',              15,             (SELECT COUNT(*) FROM dbo.LocationSocialMedia)
    UNION ALL SELECT 'ServiceCategory',                  12,             (SELECT COUNT(*) FROM dbo.ServiceCategory)
    UNION ALL SELECT 'Service',                          22,             (SELECT COUNT(*) FROM dbo.Service)
) AS t;