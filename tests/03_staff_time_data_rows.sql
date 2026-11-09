-- Verify row counts for the Staff & time cluster against the expected seed data.
-- Every row should show Result = 'OK'. A 'CHECK' means the seed file didn't
-- fully run, or ran twice (in which case drop, recreate, and reseed).
SELECT t.TableName, t.Expected, t.Actual,
       CASE WHEN t.Actual = t.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
              SELECT 'Staff'             AS TableName, 15 AS Expected, (SELECT COUNT(*) FROM dbo.Staff)             AS Actual
    UNION ALL SELECT 'StaffService',                   30,             (SELECT COUNT(*) FROM dbo.StaffService)
    UNION ALL SELECT 'StaffAvailability',              15,             (SELECT COUNT(*) FROM dbo.StaffAvailability)
    UNION ALL SELECT 'TimeSlot',                       26,             (SELECT COUNT(*) FROM dbo.TimeSlot)
) AS t;

-- Should return no rows: rows pointing to a parent that doesn't exist.
SELECT 'Staff' AS TableName, s.StaffID AS RowID, 'LocationID' AS FKColumn, s.LocationID AS FKValue
FROM dbo.Staff s
LEFT JOIN dbo.Location l ON l.LocationID = s.LocationID
WHERE l.LocationID IS NULL
UNION ALL
SELECT 'StaffService', ss.StaffServiceID, 'StaffID', ss.StaffID
FROM dbo.StaffService ss
LEFT JOIN dbo.Staff s ON s.StaffID = ss.StaffID
WHERE s.StaffID IS NULL
UNION ALL
SELECT 'StaffService', ss.StaffServiceID, 'ServiceID', ss.ServiceID
FROM dbo.StaffService ss
LEFT JOIN dbo.Service sv ON sv.ServiceID = ss.ServiceID
WHERE sv.ServiceID IS NULL
UNION ALL
SELECT 'StaffAvailability', sa.StaffAvailabilityID, 'StaffID', sa.StaffID
FROM dbo.StaffAvailability sa
LEFT JOIN dbo.Staff s ON s.StaffID = sa.StaffID
WHERE s.StaffID IS NULL
UNION ALL
SELECT 'TimeSlot', ts.TimeSlotID, 'StaffAvailabilityID', ts.StaffAvailabilityID
FROM dbo.TimeSlot ts
LEFT JOIN dbo.StaffAvailability sa ON sa.StaffAvailabilityID = ts.StaffAvailabilityID
WHERE sa.StaffAvailabilityID IS NULL;

-- Should return no rows: a staff member assigned a service that their own
-- location's business doesn't offer.
SELECT ss.StaffServiceID, ss.StaffID, st.LocationID, ss.ServiceID
FROM dbo.StaffService ss
JOIN dbo.Staff st           ON st.StaffID = ss.StaffID
JOIN dbo.Location l         ON l.LocationID = st.LocationID
JOIN dbo.Service sv         ON sv.ServiceID = ss.ServiceID
JOIN dbo.ServiceCategory sc ON sc.ServiceCategoryID = sv.ServiceCategoryID
WHERE sc.BusinessID <> l.BusinessID;

-- Should return no rows: a time slot that falls outside its availability
-- window (different date, starts too early, or ends too late).
SELECT ts.TimeSlotID, ts.Date, ts.StartTime, ts.EndTime,
       sa.StaffAvailabilityID, sa.AvailabilityDate, sa.StartTime AS WindowStart, sa.EndTime AS WindowEnd
FROM dbo.TimeSlot ts
JOIN dbo.StaffAvailability sa ON sa.StaffAvailabilityID = ts.StaffAvailabilityID
WHERE ts.Date <> sa.AvailabilityDate
   OR ts.StartTime < sa.StartTime
   OR ts.EndTime   > sa.EndTime;

-- Should return no rows: two slots carved from the same window that overlap.
SELECT a.TimeSlotID AS SlotA, b.TimeSlotID AS SlotB, a.StaffAvailabilityID
FROM dbo.TimeSlot a
JOIN dbo.TimeSlot b
  ON b.StaffAvailabilityID = a.StaffAvailabilityID
 AND b.TimeSlotID > a.TimeSlotID
 AND a.StartTime < b.EndTime
 AND b.StartTime < a.EndTime;
GO
