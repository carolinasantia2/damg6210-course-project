-- ---------- Tests: AppointmentService + whole schema ----------
-- Run last, after all five clusters are created and seeded.
-- Every row in every section should show Result = 'OK'.
-- FK and CHECK rules are already enforced by the database, so they aren't
-- re-tested here. These tests cover what the constraints can't enforce:
-- rules that compare rows across tables. Section 4 checks the assignment's
-- schema requirements and doubles as the Task 7 clean-run check.

-- 1. Row counts against the expected seed data.
--    A 'CHECK' means the seed file didn't fully run, or ran twice
--    (in which case drop, recreate, and reseed).
SELECT t.TableName, t.Expected, t.Actual,
       CASE WHEN t.Actual = t.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
              SELECT 'AppointmentService (total)' AS TableName, 21 AS Expected, (SELECT COUNT(*) FROM dbo.AppointmentService) AS Actual
    UNION ALL SELECT 'AppointmentService (core)',  15, (SELECT COUNT(*) FROM dbo.AppointmentService WHERE ParentAppointmentServiceID IS NULL)
    UNION ALL SELECT 'AppointmentService (add-on)', 6, (SELECT COUNT(*) FROM dbo.AppointmentService WHERE ParentAppointmentServiceID IS NOT NULL)
) AS t;

-- 2. Schema objects: confirms the current version of the CREATE file was
--    run. A 'CHECK' usually means an old copy of the file was run, or a
--    constraint was added/removed without updating this test.
SELECT s.ObjectType, s.Expected, s.Actual,
       CASE WHEN s.Actual = s.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
    SELECT 'CHECK constraints (Status, no self-parent)' AS ObjectType, 2 AS Expected,
           (SELECT COUNT(*) FROM sys.check_constraints
             WHERE parent_object_id = OBJECT_ID('dbo.AppointmentService')) AS Actual
    UNION ALL SELECT 'Foreign keys (Appointment, Service, Parent, TimeSlot, Staff)', 5,
           (SELECT COUNT(*) FROM sys.foreign_keys
             WHERE parent_object_id = OBJECT_ID('dbo.AppointmentService'))
    UNION ALL SELECT 'Filtered unique index (UQ_AppointmentService_TimeSlotID)', 1,
           (SELECT COUNT(*) FROM sys.indexes
             WHERE object_id = OBJECT_ID('dbo.AppointmentService')
               AND name = 'UQ_AppointmentService_TimeSlotID'
               AND is_unique = 1 AND has_filter = 1)
) AS s;

-- 3. Data sanity. Each check counts problem rows, so 0 = OK.
SELECT chk.CheckName, chk.Problems,
       CASE WHEN chk.Problems = 0 THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
    -- Who and when: the staff member, slot, and service must agree.
    SELECT 'Staff on the row doesn''t own the time slot' AS CheckName,
           (SELECT COUNT(*)
              FROM dbo.AppointmentService aps
              JOIN dbo.TimeSlot ts          ON ts.TimeSlotID = aps.TimeSlotID
              JOIN dbo.StaffAvailability sa ON sa.StaffAvailabilityID = ts.StaffAvailabilityID
             WHERE sa.StaffID <> aps.StaffID) AS Problems

    UNION ALL SELECT 'Staff doesn''t perform the service (no StaffService row)',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService aps
             WHERE NOT EXISTS (SELECT 1 FROM dbo.StaffService ss
                                WHERE ss.StaffID = aps.StaffID AND ss.ServiceID = aps.ServiceID))

    UNION ALL SELECT 'Slot length doesn''t match the service duration',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService aps
              JOIN dbo.TimeSlot ts ON ts.TimeSlotID = aps.TimeSlotID
              JOIN dbo.Service sv  ON sv.ServiceID = aps.ServiceID
             WHERE DATEDIFF(MINUTE, ts.StartTime, ts.EndTime) <> sv.EstimatedDuration)

    UNION ALL SELECT 'Appointment''s services span more than one location',
           (SELECT COUNT(*) FROM (
                SELECT aps.AppointmentID
                  FROM dbo.AppointmentService aps
                  JOIN dbo.Staff st ON st.StaffID = aps.StaffID
                 GROUP BY aps.AppointmentID
                HAVING COUNT(DISTINCT st.LocationID) > 1) AS d)

    UNION ALL SELECT 'Appointment with no services',
           (SELECT COUNT(*)
              FROM dbo.Appointment a
             WHERE NOT EXISTS (SELECT 1 FROM dbo.AppointmentService aps
                                WHERE aps.AppointmentID = a.AppointmentID))

    UNION ALL SELECT 'Service slot starts before the appointment was booked',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService aps
              JOIN dbo.Appointment a ON a.AppointmentID = aps.AppointmentID
              JOIN dbo.TimeSlot ts   ON ts.TimeSlotID = aps.TimeSlotID
             WHERE CAST(ts.Date AS DATETIME) + CAST(ts.StartTime AS DATETIME) < a.BookedAt)

    -- Add-ons: the self-reference must stay one level deep, within one
    -- appointment, and line up with the parent's slot and status.
    UNION ALL SELECT 'Add-on''s parent is in a different appointment',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService ch
              JOIN dbo.AppointmentService par ON par.AppointmentServiceID = ch.ParentAppointmentServiceID
             WHERE ch.AppointmentID <> par.AppointmentID)

    UNION ALL SELECT 'Add-on''s parent is itself an add-on',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService ch
              JOIN dbo.AppointmentService par ON par.AppointmentServiceID = ch.ParentAppointmentServiceID
             WHERE par.ParentAppointmentServiceID IS NOT NULL)

    UNION ALL SELECT 'Add-on slot isn''t on the parent''s day, after the parent ends',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService ch
              JOIN dbo.AppointmentService par ON par.AppointmentServiceID = ch.ParentAppointmentServiceID
              JOIN dbo.TimeSlot cts ON cts.TimeSlotID = ch.TimeSlotID
              JOIN dbo.TimeSlot pts ON pts.TimeSlotID = par.TimeSlotID
             WHERE cts.Date <> pts.Date OR cts.StartTime < pts.EndTime)

    UNION ALL SELECT 'Add-on status differs from its parent''s',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService ch
              JOIN dbo.AppointmentService par ON par.AppointmentServiceID = ch.ParentAppointmentServiceID
             WHERE ch.Status <> par.Status)

    -- Agreement with the outcomes cluster.
    UNION ALL SELECT 'Cancelled appointment with a service not marked Cancelled',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService aps
              JOIN dbo.Cancellation c ON c.AppointmentID = aps.AppointmentID
             WHERE aps.Status <> 'Cancelled')

    UNION ALL SELECT 'Service marked Cancelled with no Cancellation record',
           (SELECT COUNT(*)
              FROM dbo.AppointmentService aps
             WHERE aps.Status = 'Cancelled'
               AND NOT EXISTS (SELECT 1 FROM dbo.Cancellation c
                                WHERE c.AppointmentID = aps.AppointmentID))

    UNION ALL SELECT 'Cancellation at or after the service start time',
           (SELECT COUNT(*)
              FROM dbo.Cancellation c
              JOIN dbo.AppointmentService aps ON aps.AppointmentID = c.AppointmentID
              JOIN dbo.TimeSlot ts            ON ts.TimeSlotID = aps.TimeSlotID
             WHERE c.CancelledAt >= CAST(ts.Date AS DATETIME) + CAST(ts.StartTime AS DATETIME))

    UNION ALL SELECT 'Full Payment amount doesn''t equal the services'' total',
           (SELECT COUNT(*)
              FROM dbo.Payment p
             WHERE p.Type = 'Full Payment' AND p.Status = 'Completed'
               AND p.Amount <> (SELECT SUM(sv.Price)
                                  FROM dbo.AppointmentService aps
                                  JOIN dbo.Service sv ON sv.ServiceID = aps.ServiceID
                                 WHERE aps.AppointmentID = p.AppointmentID))

    -- Fee rule: no fee if the business cancelled or the customer gave at
    -- least the policy's notice. Otherwise the policy's FeeAmount, capped
    -- at what was actually paid (the fee is withheld from the deposit).
    -- The location comes from the core service's staff member, and the
    -- notice is measured to the core service's slot.
    UNION ALL SELECT 'Cancellation fee doesn''t follow the location''s policy',
           (SELECT COUNT(*)
              FROM (SELECT c.FeeCharged,
                           CASE
                             WHEN c.CancelledBy = 'Business' THEN 0
                             WHEN DATEDIFF(MINUTE, c.CancelledAt,
                                           CAST(ts.Date AS DATETIME) + CAST(ts.StartTime AS DATETIME))
                                  >= cp.NoticePeriod * 60 THEN 0
                             WHEN cp.FeeAmount < ISNULL(paid.Total, 0) THEN cp.FeeAmount
                             ELSE ISNULL(paid.Total, 0)
                           END AS ExpectedFee
                      FROM dbo.Cancellation c
                      JOIN dbo.AppointmentService aps  ON aps.AppointmentID = c.AppointmentID
                                                      AND aps.ParentAppointmentServiceID IS NULL
                      JOIN dbo.TimeSlot ts             ON ts.TimeSlotID = aps.TimeSlotID
                      JOIN dbo.Staff st                ON st.StaffID = aps.StaffID
                      JOIN dbo.CancellationPolicy cp   ON cp.LocationID = st.LocationID
                      OUTER APPLY (SELECT SUM(p.Amount) AS Total
                                     FROM dbo.Payment p
                                    WHERE p.AppointmentID = c.AppointmentID
                                      AND p.Status IN ('Completed', 'Refunded')) AS paid
                   ) AS f
             WHERE f.FeeCharged <> f.ExpectedFee)
) AS chk;

-- 4. Whole-schema requirements from the assignment. Run this after the
--    final dist/ scripts in Task 7 as the clean-run sign-off.
SELECT r.Requirement, r.Expected, r.Actual,
       CASE WHEN r.Actual = r.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
    SELECT 'Tables in dbo' AS Requirement, 17 AS Expected,
           (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo')) AS Actual

    UNION ALL SELECT 'Tables without a primary key', 0,
           (SELECT COUNT(*) FROM sys.tables t
             WHERE t.schema_id = SCHEMA_ID('dbo')
               AND NOT EXISTS (SELECT 1 FROM sys.key_constraints k
                                WHERE k.parent_object_id = t.object_id AND k.type = 'PK'))

    UNION ALL SELECT 'Tables without an identity column', 0,
           (SELECT COUNT(*) FROM sys.tables t
             WHERE t.schema_id = SCHEMA_ID('dbo')
               AND NOT EXISTS (SELECT 1 FROM sys.identity_columns ic
                                WHERE ic.object_id = t.object_id))

    UNION ALL SELECT 'Tables with fewer than 10 rows', 0,
           (SELECT COUNT(*) FROM (
                SELECT t.object_id
                  FROM sys.tables t
                  JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
                 WHERE t.schema_id = SCHEMA_ID('dbo')
                 GROUP BY t.object_id
                HAVING SUM(p.rows) < 10) AS d)

    -- The assignment requires at least 3. Exact counts are listed so that
    -- a missing or extra constraint gets noticed: foundation 4, booking
    -- core 7, staff & time 4, outcomes 8, appointment service 2.
    UNION ALL SELECT 'CHECK constraints (requirement: 3+)', 25,
           (SELECT COUNT(*) FROM sys.check_constraints c
              JOIN sys.tables t ON t.object_id = c.parent_object_id
             WHERE t.schema_id = SCHEMA_ID('dbo'))

    -- Foundation 5, booking core 2, staff & time 5, outcomes 5,
    -- appointment service 5.
    UNION ALL SELECT 'Foreign keys', 22,
           (SELECT COUNT(*) FROM sys.foreign_keys f
              JOIN sys.tables t ON t.object_id = f.parent_object_id
             WHERE t.schema_id = SCHEMA_ID('dbo'))
) AS r;
GO