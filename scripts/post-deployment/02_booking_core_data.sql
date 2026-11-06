-- Customer table 
INSERT INTO dbo.Customer
    (FirstName, LastName, PhoneNumber, Email, CustomerPreferredContact, RegistrationDate)
VALUES
    ('Emily',    'Chen',      '617-555-0101', 'emily.chen@example.com',      'Email', '2025-01-14'),
    ('Marcus',   'Johnson',   '617-555-0102', 'marcus.johnson@example.com',  'SMS',   '2025-02-03'),
    ('Sofia',    'Ramirez',   '857-555-0103', 'sofia.ramirez@example.com',   'Email', '2025-03-22'),
    ('Daniel',   'Kim',       '781-555-0104', NULL,                          'Phone', '2025-04-10'),
    ('Aisha',    'Patel',     '617-555-0105', 'aisha.patel@example.com',     'SMS',   '2025-05-01'),
    ('Liam',     'O''Brien',  NULL,           'liam.obrien@example.com',     'Email', '2025-05-19'),
    ('Hannah',   'Nguyen',    '857-555-0107', 'hannah.nguyen@example.com',   'Email', '2025-06-30'),
    ('Carlos',   'Silva',     '781-555-0108', 'carlos.silva@example.com',    'Phone', '2025-08-12'),
    ('Grace',    'Thompson',  '617-555-0109', 'grace.thompson@example.com',  'Email', '2025-10-05'),
    ('Yuki',     'Tanaka',    '857-555-0110', 'yuki.tanaka@example.com',     'SMS',   '2026-01-17'),
    ('Olivia',   'Martin',    '781-555-0111', 'olivia.martin@example.com',   'Email', '2026-03-08'),
    ('Ethan',    'Brooks',    '617-555-0112', NULL,                          'SMS',   '2026-06-21');

--PaymentMethod table 
INSERT INTO dbo.PaymentMethod (CustomerID, CardType, LastFourDigits, ExpirationDate)
VALUES
    (1,  'Visa',       '4242', '2028-08-31'),
    (1,  'Amex',       '1005', '2027-03-31'),
    (2,  'Mastercard', '5454', '2029-01-31'),
    (3,  'Visa',       '1881', '2027-11-30'),
    (4,  'Debit',      '3310', '2028-04-30'),
    (5,  'Discover',   '6011', '2030-06-30'),
    (6,  'Visa',       '7720', '2026-12-31'),
    (7,  'Mastercard', '2231', '2028-02-29'),
    (8,  'Visa',       '9087', '2029-09-30'),
    (9,  'Amex',       '0045', '2027-07-31'),
    (10, 'Mastercard', '4410', '2030-10-31'),
    (11, 'Debit',      '8862', '2028-12-31');
GO
 
--Appointment table 
INSERT INTO dbo.Appointment (CustomerID, BookedAt)
VALUES
    (1,  '2025-02-10 09:15:00'),
    (1,  '2025-09-02 18:40:00'),
    (2,  '2025-03-14 12:05:00'),
    (3,  '2025-04-01 08:30:00'),
    (4,  '2025-04-18 16:20:00'),
    (5,  '2025-05-07 10:00:00'),
    (5,  '2026-02-11 14:45:00'),
    (6,  '2025-06-02 19:10:00'),
    (7,  '2025-07-15 11:25:00'),
    (8,  '2025-08-20 13:50:00'),
    (9,  '2025-10-09 17:35:00'),
    (10, '2026-01-25 09:55:00'),
    (11, '2026-03-12 15:00:00'),
    (12, '2026-07-01 20:15:00'),
    (3,  '2026-10-28 08:05:00');
GO