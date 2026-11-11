-- ---------- Seed data: Staff & time cluster ----------
-- Run AFTER the foundation seed (01_foundation_data.sql) and after the four
-- staff & time tables exist. Assumes the tables are freshly created and
-- empty, so IDENTITY values start at 1 and increment in insertion order.
-- That's why child-table inserts below reference plain integers for FK
-- columns instead of looking them up.
-- If you ever run this against a non-empty table, those hardcoded FK
-- values will be wrong. Run scripts/pre-deployment/drop_all_tables.sql
-- and the CREATE TABLE files first to reset to a clean state.
--
-- Insert order: Staff -> StaffService -> StaffAvailability -> TimeSlot.

-- Staff: 15 rows (StaffID 1-15 in the order below).
-- Every location 1-13 has at least one staff member. Two locations show
-- the 1:M side of Location -> Staff:
--   Location 1 (Luxe Hair Studio, Boston)   = Staff 1 and 2
--   Location 3 (Serenity Medspa)            = Staff 4 and 15
INSERT INTO dbo.Staff (LocationID, FirstName, LastName, Role, Email, PhoneNumber) VALUES
(1,  'Ava',      'Morgan',  'Senior Stylist',     'ava.morgan@luxehairstudio.example.com',       '617-555-0301'),
(1,  'Noah',     'Bennett', 'Colorist',           'noah.bennett@luxehairstudio.example.com',     '617-555-0302'),
(2,  'Mia',      'Lopez',   'Nail Technician',    'mia.lopez@bloomnailbar.example.com',          '617-555-0303'),
(3,  'Priya',    'Shah',    'Esthetician',        'priya.shah@serenitymedspa.example.com',       '617-555-0304'),
(4,  'Jake',     'Turner',  'Pet Groomer',        'jake.turner@pawfectgrooming.example.com',     '617-555-0305'),
(5,  'Leo',      'Garcia',  'Barber',             'leo.garcia@urbancutsbarbershop.example.com',  '617-555-0306'),
(6,  'Chloe',    'Park',    'Esthetician',        'chloe.park@glowbeautylounge.example.com',     '617-555-0307'),
(7,  'Isabella', 'Rossi',   'Massage Therapist',  'isabella.rossi@tranquilspa.example.com',      '617-555-0308'),
(8,  'Zoe',      'Walsh',   'Stylist',            'zoe.walsh@chichairco.example.com',            '617-555-0309'),
(9,  'Lily',     'Huang',   'Nail Artist',        'lily.huang@polishednails.example.com',        '617-555-0310'),
(10, 'Owen',     'Reed',    'Pet Groomer',        'owen.reed@furandfeatherpetspa.example.com',   '617-555-0311'),
(11, 'Sara',     'Kim',     'Stylist',            'sara.kim@luxehairstudio.example.com',         '617-555-0312'),
(12, 'Marco',    'Diaz',    'Barber',             'marco.diaz@urbancutsbarbershop.example.com',  NULL),
(13, 'Nina',     'O''Neil', 'Massage Therapist',  'nina.oneil@tranquilspa.example.com',          '617-555-0314'),
(3,  'Rachel',   'Adams',   'Laser Technician',   'rachel.adams@serenitymedspa.example.com',     '617-555-0315');
GO

-- StaffService: 30 rows. A staff member only performs services offered by
-- their own location's business (Location -> Business -> ServiceCategory
-- -> Service). Services each location can offer:
--   L1, L11 (Luxe)       : 1, 11, 12, 13, 14
--   L2 (Bloom)           : 2, 15, 16
--   L3 (Serenity)        : 3, 21, 22
--   L4 (Pawfect)         : 4, 17
--   L5, L12 (Urban Cuts) : 5, 18
--   L6 (Glow)            : 6
--   L7, L13 (Tranquil)   : 7, 19, 20
--   L8 (Chic)            : 8
--   L9 (Polished)        : 9
--   L10 (Fur & Feather)  : 10
-- Many-to-many in both directions: Staff 1 performs several services, and
-- Service 1 (Women's Haircut) is performed by Staff 1, 2, and 12 at
-- different proficiency levels.
INSERT INTO dbo.StaffService (StaffID, ServiceID, ProficiencyLevel) VALUES
(1,  1,  'Expert'),        -- Ava: Women's Haircut
(1,  11, 'Expert'),        -- Ava: Blowout
(1,  12, 'Intermediate'),  -- Ava: Deep Conditioning (add-on)
(2,  13, 'Expert'),        -- Noah: Single-Process Color
(2,  14, 'Expert'),        -- Noah: Full Highlights
(2,  1,  'Intermediate'),  -- Noah: Women's Haircut
(3,  2,  'Expert'),        -- Mia: Classic Manicure
(3,  15, 'Intermediate'),  -- Mia: Gel Pedicure
(3,  16, 'Expert'),        -- Mia: Paraffin Hand Treatment (add-on)
(4,  3,  'Expert'),        -- Priya: Signature Facial
(4,  22, 'Intermediate'),  -- Priya: LED Light Therapy (add-on)
(5,  4,  'Expert'),        -- Jake: Full-Service Dog Grooming
(5,  17, 'Beginner'),      -- Jake: Teeth Brushing (add-on)
(6,  5,  'Expert'),        -- Leo: Men's Haircut & Beard Trim
(6,  18, 'Intermediate'),  -- Leo: Hot Towel Shave
(7,  6,  'Expert'),        -- Chloe: Eyebrow Waxing
(8,  7,  'Expert'),        -- Isabella: Swedish Massage
(8,  19, 'Intermediate'),  -- Isabella: Hot Stone Massage
(8,  20, 'Expert'),        -- Isabella: Aromatherapy Upgrade (add-on)
(9,  8,  'Expert'),        -- Zoe: Hair Extensions Application
(10, 9,  'Expert'),        -- Lily: Nail Art Design
(11, 10, 'Expert'),        -- Owen: Cat Grooming
(12, 1,  'Intermediate'),  -- Sara: Women's Haircut
(12, 11, 'Expert'),        -- Sara: Blowout
(13, 5,  'Expert'),        -- Marco: Men's Haircut & Beard Trim
(13, 18, 'Expert'),        -- Marco: Hot Towel Shave
(14, 7,  'Intermediate'),  -- Nina: Swedish Massage
(14, 19, 'Expert'),        -- Nina: Hot Stone Massage
(15, 21, 'Expert'),        -- Rachel: Laser Hair Removal - Small Area
(15, 22, 'Expert');        -- Rachel: LED Light Therapy (add-on)
GO

-- StaffAvailability: 15 rows (StaffAvailabilityID 1-15 in the order below).
-- Each window falls on a day the staff member's location is open and
-- within its operating hours. Dates run from Feb 2025 to Nov 2026, each a
-- few days after one of the booking-core appointments' BookedAt dates, so
-- AppointmentService can pair appointments with slots that come after the
-- booking was made. Availability 1 and 7 each generate three TimeSlots,
-- showing the 1:M side of StaffAvailability -> TimeSlot.
INSERT INTO dbo.StaffAvailability (StaffID, AvailabilityDate, StartTime, EndTime) VALUES
(1,  '2025-02-17', '09:00', '17:00'),  -- 1  Ava,      Luxe Boston (Mon)
(3,  '2025-03-18', '10:00', '18:00'),  -- 2  Mia,      Bloom (Tue)
(4,  '2025-04-07', '09:00', '17:00'),  -- 3  Priya,    Serenity (Mon)
(5,  '2025-04-22', '08:00', '16:00'),  -- 4  Jake,     Pawfect (Tue)
(6,  '2025-05-13', '09:00', '17:00'),  -- 5  Leo,      Urban Cuts Somerville (Tue)
(7,  '2025-06-09', '10:00', '18:00'),  -- 6  Chloe,    Glow (Mon)
(8,  '2025-07-21', '12:00', '20:00'),  -- 7  Isabella, Tranquil Boston (Mon)
(9,  '2025-08-26', '10:00', '18:00'),  -- 8  Zoe,      Chic (Tue)
(2,  '2025-09-09', '09:00', '17:00'),  -- 9  Noah,     Luxe Boston (Tue)
(10, '2025-10-14', '09:00', '17:00'),  -- 10 Lily,     Polished (Tue)
(11, '2026-01-31', '08:00', '14:00'),  -- 11 Owen,     Fur & Feather (Sat)
(12, '2026-02-17', '10:00', '18:00'),  -- 12 Sara,     Luxe Cambridge (Tue)
(13, '2026-03-17', '07:00', '15:00'),  -- 13 Marco,    Urban Cuts downtown (Tue)
(14, '2026-07-07', '13:00', '21:00'),  -- 14 Nina,     Tranquil Brookline (Tue)
(15, '2026-11-03', '09:00', '15:00');  -- 15 Rachel,   Serenity (Tue)
GO

-- TimeSlot: 26 rows. Each slot sits inside its availability window (same
-- date, between the window's start and end) and is sized to one service
-- that staff member performs. Slots within a window never overlap. An
-- add-on slot starts right where its core service's slot ends, so
-- AppointmentService can pair them (e.g. slots 1 + 2: haircut, then deep
-- conditioning). Comment = TimeSlotID and the service it fits.
INSERT INTO dbo.TimeSlot (StaffAvailabilityID, Date, StartTime, EndTime) VALUES
(1,  '2025-02-17', '09:00', '10:00'),  -- 1  Women's Haircut (60)
(1,  '2025-02-17', '10:00', '10:15'),  -- 2  Deep Conditioning add-on (15)
(1,  '2025-02-17', '10:30', '11:15'),  -- 3  Blowout (45)
(2,  '2025-03-18', '10:00', '10:30'),  -- 4  Classic Manicure (30)
(2,  '2025-03-18', '10:30', '10:45'),  -- 5  Paraffin Hand add-on (15)
(2,  '2025-03-18', '13:00', '14:00'),  -- 6  Gel Pedicure (60)
(3,  '2025-04-07', '09:00', '10:00'),  -- 7  Signature Facial (60)
(3,  '2025-04-07', '10:00', '10:20'),  -- 8  LED Light Therapy add-on (20)
(4,  '2025-04-22', '08:00', '09:30'),  -- 9  Full-Service Dog Grooming (90)
(4,  '2025-04-22', '09:30', '09:40'),  -- 10 Teeth Brushing add-on (10)
(5,  '2025-05-13', '09:00', '09:45'),  -- 11 Men's Haircut & Beard Trim (45)
(5,  '2025-05-13', '11:00', '11:30'),  -- 12 Hot Towel Shave (30)
(6,  '2025-06-09', '10:00', '10:15'),  -- 13 Eyebrow Waxing (15)
(7,  '2025-07-21', '12:00', '13:00'),  -- 14 Swedish Massage (60)
(7,  '2025-07-21', '14:00', '15:30'),  -- 15 Hot Stone Massage (90)
(7,  '2025-07-21', '15:30', '15:45'),  -- 16 Aromatherapy add-on (15)
(8,  '2025-08-26', '10:00', '12:00'),  -- 17 Hair Extensions Application (120)
(9,  '2025-09-09', '09:00', '10:30'),  -- 18 Single-Process Color (90)
(9,  '2025-09-09', '11:00', '13:30'),  -- 19 Full Highlights (150)
(10, '2025-10-14', '09:00', '09:45'),  -- 20 Nail Art Design (45)
(11, '2026-01-31', '08:00', '08:45'),  -- 21 Cat Grooming (45)
(12, '2026-02-17', '10:00', '10:45'),  -- 22 Blowout (45)
(13, '2026-03-17', '07:00', '07:45'),  -- 23 Men's Haircut & Beard Trim (45)
(14, '2026-07-07', '13:00', '14:30'),  -- 24 Hot Stone Massage (90)
(15, '2026-11-03', '09:00', '09:30'),  -- 25 Laser Hair Removal (30)
(15, '2026-11-03', '09:30', '09:50');  -- 26 LED Light Therapy add-on (20)
GO
