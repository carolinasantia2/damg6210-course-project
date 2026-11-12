-- ---------- Tests: Outcomes cluster ----------
-- Run after the booking core and outcomes tables are created and seeded.
-- Every row in every section should show Result = 'OK'.
-- FK and CHECK rules are already enforced by the database, so they aren't
-- re-tested here. These tests cover what the constraints can't enforce:
-- rules that compare rows across tables.
--
-- Not covered here: whether a cancellation fee matches the location's
-- CancellationPolicy. An appointment's location is only known through
-- AppointmentService -> Staff -> Location, so that check belongs in
-- tests/05_appointment_service_data_rows.sql.

-- 1. Row counts against the expected seed data.
--    A 'CHECK' means the seed file didn't fully run, or ran twice
--    (in which case drop, recreate, and reseed).
SELECT t.TableName, t.Expected, t.Actual,
       CASE WHEN t.Actual = t.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
              SELECT 'Payment'      AS TableName, 11 AS Expected, (SELECT COUNT(*) FROM dbo.Payment)      AS Actual
    UNION ALL SELECT 'Cancellation',              10,             (SELECT COUNT(*) FROM dbo.Cancellation)
    UNION ALL SELECT 'Notification',              30,             (SELECT COUNT(*) FROM dbo.Notification)
) AS t;

-- 2. Schema objects: confirms the current version of each CREATE file was
--    run. A 'CHECK' usually means an old copy of a file was run, or a
--    constraint was added/removed without updating this test.
SELECT s.ObjectType, s.Expected, s.Actual,
       CASE WHEN s.Actual = s.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
    SELECT 'CHECK constraints (Payment 3, Cancellation 3, Notification 2)' AS ObjectType, 8 AS Expected,
           (SELECT COUNT(*) FROM sys.check_constraints
             WHERE parent_object_id IN (OBJECT_ID('dbo.Payment'), OBJECT_ID('dbo.Cancellation'),
                                        OBJECT_ID('dbo.Notification'))) AS Actual
    UNION ALL SELECT 'Foreign keys (Payment 2, Cancellation 1, Notification 2)', 5,
           (SELECT COUNT(*) FROM sys.foreign_keys
             WHERE parent_object_id IN (OBJECT_ID('dbo.Payment'), OBJECT_ID('dbo.Cancellation'),
                                        OBJECT_ID('dbo.Notification')))
    UNION ALL SELECT 'UNIQUE constraints (Cancellation.AppointmentID)', 1,
           (SELECT COUNT(*) FROM sys.key_constraints
             WHERE type = 'UQ' AND parent_object_id = OBJECT_ID('dbo.Cancellation'))
) AS s;

-- 3. Data sanity. Each check counts problem rows, so 0 = OK.
SELECT chk.CheckName, chk.Problems,
       CASE WHEN chk.Problems = 0 THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
    -- Ownership: the card and the notification recipient must belong to
    -- the appointment's customer.
    SELECT 'Payment card not owned by the appointment''s customer' AS CheckName,
           (SELECT COUNT(*)
              FROM dbo.Payment p
              JOIN dbo.Appointment a    ON a.AppointmentID = p.AppointmentID
              JOIN dbo.PaymentMethod pm ON pm.PaymentMethodID = p.PaymentMethodID
             WHERE pm.CustomerID <> a.CustomerID) AS Problems

    UNION ALL SELECT 'Notification sent to someone other than the appointment''s customer',
           (SELECT COUNT(*)
              FROM dbo.Notification n
              JOIN dbo.Appointment a ON a.AppointmentID = n.AppointmentID
             WHERE n.CustomerID <> a.CustomerID)

    -- Timing: nothing can happen to an appointment before it was booked.
    UNION ALL SELECT 'Payment charged before the appointment was booked',
           (SELECT COUNT(*)
              FROM dbo.Payment p
              JOIN dbo.Appointment a ON a.AppointmentID = p.AppointmentID
             WHERE p.ChargedAt < a.BookedAt)

    UNION ALL SELECT 'Cancellation before the appointment was booked',
           (SELECT COUNT(*)
              FROM dbo.Cancellation c
              JOIN dbo.Appointment a ON a.AppointmentID = c.AppointmentID
             WHERE c.CancelledAt < a.BookedAt)

    UNION ALL SELECT 'Notification sent before the appointment was booked',
           (SELECT COUNT(*)
              FROM dbo.Notification n
              JOIN dbo.Appointment a ON a.AppointmentID = n.AppointmentID
             WHERE n.SentAt < a.BookedAt)

    -- Money: the fee kept plus the refund given can't exceed what was paid.
    -- Assumes the fee is withheld from the customer's payment(s).
    UNION ALL SELECT 'Cancellation fee + refund exceeds amount paid',
           (SELECT COUNT(*)
              FROM dbo.Cancellation c
             WHERE c.FeeCharged + c.RefundAmount >
                   ISNULL((SELECT SUM(p.Amount) FROM dbo.Payment p
                            WHERE p.AppointmentID = c.AppointmentID
                              AND p.Status IN ('Completed', 'Refunded')), 0))

    -- Consistency between tables: a refund should show on the payment,
    -- and a cancellation should have notified the customer.
    UNION ALL SELECT 'Refund issued but payment not marked Refunded',
           (SELECT COUNT(*)
              FROM dbo.Cancellation c
              JOIN dbo.Payment p ON p.AppointmentID = c.AppointmentID
             WHERE c.RefundAmount > 0 AND p.Status <> 'Refunded')

    UNION ALL SELECT 'Cancelled appointment with no Cancellation notification',
           (SELECT COUNT(*)
              FROM dbo.Cancellation c
             WHERE NOT EXISTS (SELECT 1 FROM dbo.Notification n
                                WHERE n.AppointmentID = c.AppointmentID
                                  AND n.Type = 'Cancellation'))
) AS chk;
GO