-- Run after seeding Booking Core and Outcomes. Every row count should be OK.
SELECT t.TableName, t.Expected, t.Actual,
       CASE WHEN t.Actual = t.Expected THEN 'OK' ELSE 'CHECK' END AS Result
FROM (
    SELECT 'Payment' AS TableName, 10 AS Expected, (SELECT COUNT(*) FROM dbo.Payment) AS Actual
    UNION ALL SELECT 'Cancellation', 10, (SELECT COUNT(*) FROM dbo.Cancellation)
    UNION ALL SELECT 'Notification', 12, (SELECT COUNT(*) FROM dbo.Notification)
) AS t;

-- All following orphan checks should return zero rows.
SELECT 'Payment-Appointment' AS Problem, p.PaymentID AS RowID
FROM dbo.Payment p LEFT JOIN dbo.Appointment a ON a.AppointmentID = p.AppointmentID
WHERE a.AppointmentID IS NULL
UNION ALL
SELECT 'Payment-PaymentMethod', p.PaymentID
FROM dbo.Payment p LEFT JOIN dbo.PaymentMethod pm ON pm.PaymentMethodID = p.PaymentMethodID
WHERE pm.PaymentMethodID IS NULL
UNION ALL
SELECT 'Cancellation-Appointment', c.CancellationID
FROM dbo.Cancellation c LEFT JOIN dbo.Appointment a ON a.AppointmentID = c.AppointmentID
WHERE a.AppointmentID IS NULL
UNION ALL
SELECT 'Notification-Customer', n.NotificationID
FROM dbo.Notification n LEFT JOIN dbo.Customer c ON c.CustomerID = n.CustomerID
WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'Notification-Appointment', n.NotificationID
FROM dbo.Notification n LEFT JOIN dbo.Appointment a ON a.AppointmentID = n.AppointmentID
WHERE a.AppointmentID IS NULL;

-- Check business consistency, not just FK existence.
-- Every payment method must belong to the customer who made that appointment.
SELECT p.PaymentID
FROM dbo.Payment p
JOIN dbo.Appointment a ON a.AppointmentID = p.AppointmentID
JOIN dbo.PaymentMethod pm ON pm.PaymentMethodID = p.PaymentMethodID
WHERE a.CustomerID <> pm.CustomerID;

-- Every notification recipient must own the referenced appointment.
SELECT n.NotificationID
FROM dbo.Notification n
JOIN dbo.Appointment a ON a.AppointmentID = n.AppointmentID
WHERE a.CustomerID <> n.CustomerID;
GO
