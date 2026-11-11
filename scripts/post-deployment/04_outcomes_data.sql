-- ---------- Seed data: Outcomes cluster ----------
-- Run AFTER the booking core seed (02_booking_core_data.sql) and after the
-- three outcomes tables exist. Assumes the tables are freshly created and
-- empty, so IDENTITY values start at 1 and increment in insertion order.
-- That's why the inserts below reference plain integers for FK columns
-- instead of looking them up. Hardcoded IDs rely on the booking core seed
-- creating CustomerID 1-12, AppointmentID 1-15, and PaymentMethodID 1-12.
-- If you ever run this against a non-empty table, those hardcoded FK
-- values will be wrong. Run scripts/pre-deployment/drop_all_tables.sql
-- and the CREATE TABLE files first to reset to a clean state.
--
-- Insert order: Payment -> Cancellation -> Notification.
--
-- How the 15 appointments play out. Location and services come from the
-- staff & time windows each appointment lines up with, and must match the
-- AppointmentService rows.
--
--   Appt Cust Loc  Services (total)                         Outcome
--   1    1    L1   Women's Haircut + Deep Cond. ($85)       Cancelled, deposit refunded
--   2    1    L1   Single-Process Color ($110)              Completed, paid in full
--   3    2    L2   Classic Manicure + Paraffin ($40)        Cancelled late, fee kept from deposit
--   4    3    L3   Signature Facial + LED Therapy ($160)    Completed, paid in full
--   5    4    L4   Dog Grooming + Teeth Brushing ($80)      Cancelled, deposit refunded
--   6    5    L5   Men's Haircut & Beard Trim ($40)         Completed, paid in full
--   7    5    L11  Blowout ($45)                            Cancelled late, deposit kept as fee
--   8    6    L6   Eyebrow Waxing ($20)                     Completed, paid in full
--   9    7    L7   Hot Stone + Aromatherapy ($155)          Cancelled by business, deposit refunded
--   10   8    L8   Hair Extensions ($250)                   Completed, paid in full (1st charge failed)
--   11   9    L9   Nail Art Design                          Cancelled, nothing paid
--   12   10   L10  Cat Grooming                             Cancelled, nothing paid
--   13   11   L12  Men's Haircut & Beard Trim               Cancelled by business, nothing paid
--   14   12   L13  Hot Stone Massage                        Cancelled, nothing paid
--   15   3    L3   Laser Hair Removal + LED Therapy         Cancelled, nothing paid
--
-- Ten cancellations out of 15 appointments is forced by the 10-row minimum
-- plus the one-cancellation-per-appointment rule (UNIQUE AppointmentID).

-- Payment: 11 rows.
-- Deposits are charged a few minutes after booking (BookedAt + 5 min).
-- Full payments are charged at the visit, right after the last service
-- ends, and equal the appointment's service total.
-- A deposit is 'Refunded' if its cancellation returned any money, and
-- stays 'Completed' if the whole deposit was kept as the fee.
-- PaymentMethodID always belongs to the appointment's customer.
INSERT INTO dbo.Payment (AppointmentID, PaymentMethodID, Amount, Status, ChargedAt, Type) VALUES
(1,  1,  20.00,  'Refunded',  '2025-02-10T09:20:00', 'Deposit'),       -- 1
(2,  2,  110.00, 'Completed', '2025-09-09T10:35:00', 'Full Payment'),  -- 2
(3,  3,  15.00,  'Refunded',  '2025-03-14T12:10:00', 'Deposit'),       -- 3  partial refund
(4,  4,  160.00, 'Completed', '2025-04-07T10:25:00', 'Full Payment'),  -- 4
(5,  5,  20.00,  'Refunded',  '2025-04-18T16:25:00', 'Deposit'),       -- 5
(6,  6,  40.00,  'Completed', '2025-05-13T09:50:00', 'Full Payment'),  -- 6
(7,  6,  25.00,  'Completed', '2026-02-11T14:50:00', 'Deposit'),       -- 7  kept as late fee
(8,  7,  20.00,  'Completed', '2025-06-09T10:20:00', 'Full Payment'),  -- 8
(9,  8,  30.00,  'Refunded',  '2025-07-15T11:30:00', 'Deposit'),       -- 9
(10, 9,  250.00, 'Failed',    '2025-08-26T12:05:00', 'Full Payment'),  -- 10 card declined
(10, 9,  250.00, 'Completed', '2025-08-26T12:08:00', 'Full Payment');  -- 11 retry succeeded
GO

-- Cancellation: 10 rows, one per cancelled appointment.
-- Fees follow the location's CancellationPolicy: the policy's FeeAmount is
-- charged only when the customer cancels inside the notice period, and it
-- is withheld from the deposit. Cancellations by the business never carry
-- a fee. Every cancellation falls after BookedAt and before the slot.
--   Appt 3: L2 policy 12h / $10. Cancelled 2.5h before -> $10 fee, $5 refunded.
--   Appt 7: L11 policy 24h / $25. Cancelled under 2h before -> $25 fee, $0 refunded.
--   All others were cancelled with enough notice -> no fee.
INSERT INTO dbo.Cancellation (AppointmentID, CancelledAt, CancelledBy, Reason, FeeCharged, RefundAmount) VALUES
(1,  '2025-02-12T14:30:00', 'Customer', 'Schedule conflict',               0.00, 20.00),
(3,  '2025-03-18T07:30:00', 'Customer', 'Feeling unwell',                 10.00,  5.00),
(5,  '2025-04-20T11:00:00', 'Customer', 'Pet unwell',                      0.00, 20.00),
(7,  '2026-02-17T08:15:00', 'Customer', 'Car trouble',                    25.00,  0.00),
(9,  '2025-07-17T16:00:00', 'Business', 'Therapist unavailable',           0.00, 30.00),
(11, '2025-10-11T10:00:00', 'Customer', 'Changed plans',                   0.00,  0.00),
(12, '2026-01-28T18:20:00', 'Customer', NULL,                              0.00,  0.00),
(13, '2026-03-14T09:00:00', 'Business', 'Location closed for repairs',     0.00,  0.00),
(14, '2026-07-04T12:00:00', 'Customer', 'Traveling',                       0.00,  0.00),
(15, '2026-10-31T15:00:00', 'Customer', 'Booked by mistake',               0.00,  0.00);
GO

-- Notification: 30 rows, grouped by appointment.
-- Every appointment gets a Confirmation (BookedAt + 1 min). Every
-- cancelled appointment gets a Cancellation notice (CancelledAt + 1 min).
-- Every completed appointment gets a Reminder the day before its visit.
-- DeliveryMethod always matches the customer's CustomerPreferredContact.
INSERT INTO dbo.Notification (CustomerID, AppointmentID, Type, SentAt, DeliveryMethod) VALUES
(1,  1,  'Confirmation', '2025-02-10T09:16:00', 'Email'),
(1,  1,  'Cancellation', '2025-02-12T14:31:00', 'Email'),
(1,  2,  'Confirmation', '2025-09-02T18:41:00', 'Email'),
(1,  2,  'Reminder',     '2025-09-08T09:00:00', 'Email'),
(2,  3,  'Confirmation', '2025-03-14T12:06:00', 'SMS'),
(2,  3,  'Cancellation', '2025-03-18T07:31:00', 'SMS'),
(3,  4,  'Confirmation', '2025-04-01T08:31:00', 'Email'),
(3,  4,  'Reminder',     '2025-04-06T09:00:00', 'Email'),
(4,  5,  'Confirmation', '2025-04-18T16:21:00', 'Phone'),
(4,  5,  'Cancellation', '2025-04-20T11:01:00', 'Phone'),
(5,  6,  'Confirmation', '2025-05-07T10:01:00', 'SMS'),
(5,  6,  'Reminder',     '2025-05-12T09:00:00', 'SMS'),
(5,  7,  'Confirmation', '2026-02-11T14:46:00', 'SMS'),
(5,  7,  'Cancellation', '2026-02-17T08:16:00', 'SMS'),
(6,  8,  'Confirmation', '2025-06-02T19:11:00', 'Email'),
(6,  8,  'Reminder',     '2025-06-08T10:00:00', 'Email'),
(7,  9,  'Confirmation', '2025-07-15T11:26:00', 'Email'),
(7,  9,  'Cancellation', '2025-07-17T16:01:00', 'Email'),
(8,  10, 'Confirmation', '2025-08-20T13:51:00', 'Phone'),
(8,  10, 'Reminder',     '2025-08-25T10:00:00', 'Phone'),
(9,  11, 'Confirmation', '2025-10-09T17:36:00', 'Email'),
(9,  11, 'Cancellation', '2025-10-11T10:01:00', 'Email'),
(10, 12, 'Confirmation', '2026-01-25T09:56:00', 'SMS'),
(10, 12, 'Cancellation', '2026-01-28T18:21:00', 'SMS'),
(11, 13, 'Confirmation', '2026-03-12T15:01:00', 'Email'),
(11, 13, 'Cancellation', '2026-03-14T09:01:00', 'Email'),
(12, 14, 'Confirmation', '2026-07-01T20:16:00', 'SMS'),
(12, 14, 'Cancellation', '2026-07-04T12:01:00', 'SMS'),
(3,  15, 'Confirmation', '2026-10-28T08:06:00', 'Email'),
(3,  15, 'Cancellation', '2026-10-31T15:01:00', 'Email');
GO