-- Verify row counts for the Booking core cluster against the expected seed data.
-- Every row should show Result = 'OK'. A 'CHECK' means the seed file didn't
-- fully run, or ran twice (in which case drop, recreate, and reseed).
SELECT t.TableName, t.Expected, t.Actual,
       CASE WHEN t.Actual = t.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
              SELECT 'Customer'      AS TableName, 12 AS Expected, (SELECT COUNT(*) FROM dbo.Customer)      AS Actual
    UNION ALL SELECT 'Appointment',                15,             (SELECT COUNT(*) FROM dbo.Appointment)
    UNION ALL SELECT 'PaymentMethod',              12,             (SELECT COUNT(*) FROM dbo.PaymentMethod)
) AS t;

-- Should return no rows: appointments or cards pointing to a customer that doesn't exist.
SELECT 'Appointment' AS TableName, a.AppointmentID AS RowID, a.CustomerID
FROM dbo.Appointment a
LEFT JOIN dbo.Customer c ON c.CustomerID = a.CustomerID
WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'PaymentMethod', p.PaymentMethodID, p.CustomerID
FROM dbo.PaymentMethod p
LEFT JOIN dbo.Customer c ON c.CustomerID = p.CustomerID
WHERE c.CustomerID IS NULL;
GO