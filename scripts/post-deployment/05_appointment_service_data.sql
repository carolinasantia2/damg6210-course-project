-- ---------- Seed data: AppointmentService ----------
-- Run AFTER seed files 01-04 and after dbo.AppointmentService exists.
-- Assumes the table is freshly created and empty, so IDENTITY values
-- start at 1 and increment in insertion order. That's why the add-on rows
-- below reference plain integers for ParentAppointmentServiceID.
-- If you ever run this against a non-empty table, those hardcoded values
-- will be wrong. Run scripts/pre-deployment/drop_all_tables.sql and the
-- CREATE TABLE files first to reset to a clean state.
--
-- Rows follow the appointment plan in 04_outcomes_data.sql: the services
-- add up to each Full Payment, appointments 2/4/6/8/10 are 'Completed',
-- and every appointment with a Cancellation row is 'Cancelled'.
-- For every row: the staff member owns the slot's availability window,
-- performs the service (StaffService), and the slot's length equals the
-- service's EstimatedDuration.
--
-- Inserted in two passes because of the self-reference: core services
-- first (ParentAppointmentServiceID NULL), then add-ons pointing to their
-- core row. A parent must exist before a child can reference it.

-- Pass 1: core services, 15 rows, one per appointment.
-- Inserted in AppointmentID order, so each core row's
-- AppointmentServiceID equals its AppointmentID (1-15).
INSERT INTO dbo.AppointmentService (AppointmentID, ServiceID, ParentAppointmentServiceID, TimeSlotID, StaffID, Status) VALUES
(1,  1,  NULL, 1,  1,  'Cancelled'),   -- 1  Women's Haircut, Ava (L1)
(2,  13, NULL, 18, 2,  'Completed'),   -- 2  Single-Process Color, Noah (L1)
(3,  2,  NULL, 4,  3,  'Cancelled'),   -- 3  Classic Manicure, Mia (L2)
(4,  3,  NULL, 7,  4,  'Completed'),   -- 4  Signature Facial, Priya (L3)
(5,  4,  NULL, 9,  5,  'Cancelled'),   -- 5  Full-Service Dog Grooming, Jake (L4)
(6,  5,  NULL, 11, 6,  'Completed'),   -- 6  Men's Haircut & Beard Trim, Leo (L5)
(7,  11, NULL, 22, 12, 'Cancelled'),   -- 7  Blowout, Sara (L11)
(8,  6,  NULL, 13, 7,  'Completed'),   -- 8  Eyebrow Waxing, Chloe (L6)
(9,  19, NULL, 15, 8,  'Cancelled'),   -- 9  Hot Stone Massage, Isabella (L7)
(10, 8,  NULL, 17, 9,  'Completed'),   -- 10 Hair Extensions Application, Zoe (L8)
(11, 9,  NULL, 20, 10, 'Cancelled'),   -- 11 Nail Art Design, Lily (L9)
(12, 10, NULL, 21, 11, 'Cancelled'),   -- 12 Cat Grooming, Owen (L10)
(13, 5,  NULL, 23, 13, 'Cancelled'),   -- 13 Men's Haircut & Beard Trim, Marco (L12)
(14, 19, NULL, 24, 14, 'Cancelled'),   -- 14 Hot Stone Massage, Nina (L13)
(15, 21, NULL, 25, 15, 'Cancelled');   -- 15 Laser Hair Removal, Rachel (L3)
GO

-- Pass 2: add-ons, 6 rows (AppointmentServiceID 16-21). Each add-on is in
-- the same appointment as its parent, done by the same staff member, in
-- the slot that starts right where the parent's slot ends. Status always
-- matches the parent's.
INSERT INTO dbo.AppointmentService (AppointmentID, ServiceID, ParentAppointmentServiceID, TimeSlotID, StaffID, Status) VALUES
(1,  12, 1,  2,  1,  'Cancelled'),   -- 16 Deep Conditioning, add-on to 1
(3,  16, 3,  5,  3,  'Cancelled'),   -- 17 Paraffin Hand Treatment, add-on to 3
(4,  22, 4,  8,  4,  'Completed'),   -- 18 LED Light Therapy, add-on to 4
(5,  17, 5,  10, 5,  'Cancelled'),   -- 19 Teeth Brushing, add-on to 5
(9,  20, 9,  16, 8,  'Cancelled'),   -- 20 Aromatherapy Upgrade, add-on to 9
(15, 22, 15, 26, 15, 'Cancelled');   -- 21 LED Light Therapy, add-on to 15
GO