-- Seed data: Outcomes cluster.
-- Run AFTER Booking Core tables and seed data have been created in a fresh database.
-- Hardcoded FK IDs rely on Booking Core seed data creating AppointmentID 1-15,
-- PaymentMethodID 1-12, and CustomerID 1-12 in that order.
-- Do not run twice without dropping and recreating the tables.
-- The PaymentMethodID in each Payment belongs to the Appointment's customer.

-- Payment: 10 rows
INSERT INTO dbo.Payment (AppointmentID, PaymentMethodID, Amount, Status, ChargedAt, Type)
VALUES
 (1,  1,  20.00, 'Completed', '2025-02-10T09:20:00', 'Deposit'),
 (2,  2,  80.00, 'Completed', '2025-09-02T18:45:00', 'Full Payment'),
 (3,  3,  15.00, 'Completed', '2025-03-14T12:10:00', 'Deposit'),
 (4,  4,  65.00, 'Completed', '2025-04-01T08:35:00', 'Full Payment'),
 (5,  5,  20.00, 'Completed', '2025-04-18T16:25:00', 'Deposit'),
 (6,  6,  75.00, 'Completed', '2025-05-07T10:05:00', 'Full Payment'),
 (7,  6,  25.00, 'Completed', '2026-02-11T14:50:00', 'Deposit'),
 (8,  7,  50.00, 'Completed', '2025-06-02T19:15:00', 'Full Payment'),
 (9,  8,  10.00, 'Completed', '2025-07-15T11:30:00', 'Deposit'),
 (10, 9,  45.00, 'Completed', '2025-08-20T13:55:00', 'Full Payment');
GO

-- Cancellation: 10 rows; one cancellation per appointment
INSERT INTO dbo.Cancellation (AppointmentID, CancelledAt, CancelledBy, Reason, FeeCharged, RefundAmount)
VALUES
 (1,  '2025-02-11T10:00:00', 'Customer', 'Schedule conflict',       0.00, 20.00),
 (2,  '2025-09-03T11:00:00', 'Customer', 'Changed plans',          10.00, 70.00),
 (3,  '2025-03-15T09:00:00', 'Customer', 'Unable to attend',        0.00, 15.00),
 (4,  '2025-04-02T12:00:00', 'Business', 'Staff unavailable',       0.00, 65.00),
 (5,  '2025-04-19T10:00:00', 'Customer', 'Travel delay',            5.00, 15.00),
 (6,  '2025-05-08T09:00:00', 'Business', 'Temporary closure',       0.00, 75.00),
 (7,  '2026-02-12T09:00:00', 'Customer', 'Personal reasons',        5.00, 20.00),
 (8,  '2025-06-03T09:00:00', 'Customer', 'Appointment no longer needed', 0.00, 50.00),
 (9,  '2025-07-16T09:00:00', 'Customer', 'Schedule conflict',       0.00, 10.00),
 (10, '2025-08-21T09:00:00', 'Business', 'Staff unavailable',       0.00, 45.00);
GO

-- Notification: 12 rows. CustomerIDs match the Appointment rows in Booking Core.
INSERT INTO dbo.Notification (CustomerID, AppointmentID, Type, SentAt, DeliveryMethod)
VALUES
 (1,  1,  'Confirmation', '2025-02-10T09:16:00', 'Email'),
 (1,  1,  'Cancellation', '2025-02-11T10:01:00', 'Email'),
 (1,  2,  'Confirmation', '2025-09-02T18:41:00', 'Email'),
 (2,  3,  'Confirmation', '2025-03-14T12:06:00', 'SMS'),
 (3,  4,  'Confirmation', '2025-04-01T08:31:00', 'Email'),
 (4,  5,  'Confirmation', '2025-04-18T16:21:00', 'Phone'),
 (5,  6,  'Confirmation', '2025-05-07T10:01:00', 'SMS'),
 (5,  7,  'Confirmation', '2026-02-11T14:46:00', 'SMS'),
 (6,  8,  'Confirmation', '2025-06-02T19:11:00', 'Email'),
 (7,  9,  'Confirmation', '2025-07-15T11:26:00', 'Email'),
 (8, 10,  'Confirmation', '2025-08-20T13:51:00', 'Phone'),
 (9, 11,  'Confirmation', '2025-10-09T17:36:00', 'Email');
GO
