-- ---------- Seed data: Foundation cluster ----------
-- Run AFTER the six foundation tables exist. Assumes the tables are
-- freshly created and empty, so IDENTITY values start at 1 and increment
-- in insertion order. That's why child-table inserts below reference
-- plain integers for FK columns instead of looking them up.
-- If you ever run this against a non-empty table, those hardcoded FK
-- values will be wrong. Run scripts/pre-deployment/drop_all_tables.sql
-- and the CREATE TABLE files first to reset to a clean state.
--
-- Insert order: Business -> Location -> CancellationPolicy ->
-- LocationSocialMedia -> ServiceCategory -> Service.

-- Business: 10 rows.
INSERT INTO dbo.Business (Name, Description) VALUES
('Luxe Hair Studio', 'Upscale hair salon specializing in color and styling'),
('Bloom Nail Bar', 'Nail salon offering manicures, pedicures, and nail art'),
('Serenity Medspa', 'Medical spa offering skincare and wellness treatments'),
('Pawfect Grooming', 'Full-service pet grooming for dogs and cats'),
('Urban Cuts Barbershop', 'Classic and modern barbering services'),
('Glow Beauty Lounge', 'Beauty bar offering facials, waxing, and lashes'),
('Tranquil Spa & Wellness', 'Day spa offering massage and body treatments'),
('Chic Hair Co.', 'Boutique hair salon for cuts and extensions'),
('Polished Nails & Co.', 'Nail salon with a focus on nail art and gel services'),
('Fur & Feather Pet Spa', 'Pet spa offering grooming and bathing services');
GO

-- Location: 13 rows. 1-10 are one per business (BusinessID 1-10).
-- 11-13 are second locations for three businesses:
--   11 = Luxe Hair Studio (Business 1), Cambridge
--   12 = Urban Cuts Barbershop (Business 5), downtown Boston
--   13 = Tranquil Spa & Wellness (Business 7), Brookline
INSERT INTO dbo.Location (BusinessID, Street, City, State, Zip, OperatingHours, ContactPhone, Website) VALUES
(1,  '120 Newbury St', 'Boston', 'MA', '02116', 'Mon-Sat 9am-7pm', '617-555-0101', 'https://luxehairstudio.example.com'),
(2,  '45 Boylston St', 'Boston', 'MA', '02116', 'Tue-Sun 10am-8pm', '617-555-0102', 'https://bloomnailbar.example.com'),
(3,  '200 Berkeley St', 'Boston', 'MA', '02116', 'Mon-Fri 9am-6pm', '617-555-0103', 'https://serenitymedspa.example.com'),
(4,  '78 Harvard Ave', 'Brookline', 'MA', '02446', 'Mon-Sat 8am-6pm', '617-555-0104', 'https://pawfectgrooming.example.com'),
(5,  '310 Elm St', 'Somerville', 'MA', '02144', 'Tue-Sat 9am-7pm', '617-555-0105', 'https://urbancutsbarbershop.example.com'),
(6,  '15 Beacon St', 'Boston', 'MA', '02108', 'Mon-Sun 10am-7pm', '617-555-0106', 'https://glowbeautylounge.example.com'),
(7,  '500 Commonwealth Ave', 'Boston', 'MA', '02215', 'Mon-Sat 9am-8pm', '617-555-0107', 'https://tranquilspa.example.com'),
(8,  '88 Massachusetts Ave', 'Cambridge', 'MA', '02139', 'Tue-Sat 10am-6pm', '617-555-0108', 'https://chichairco.example.com'),
(9,  '22 Main St', 'Medford', 'MA', '02155', 'Mon-Sat 9am-7pm', '617-555-0109', 'https://polishednails.example.com'),
(10, '60 High St', 'Quincy', 'MA', '02169', 'Mon-Sat 8am-6pm', '617-555-0110', 'https://furandfeatherpetspa.example.com'),
(1,  '1350 Cambridge St', 'Cambridge', 'MA', '02139', 'Tue-Sat 10am-7pm', '617-555-0111', 'https://luxehairstudio.example.com'),
(5,  '75 State St', 'Boston', 'MA', '02109', 'Mon-Fri 7am-7pm', '617-555-0112', 'https://urbancutsbarbershop.example.com'),
(7,  '1600 Beacon St', 'Brookline', 'MA', '02446', 'Mon-Sun 9am-9pm', '617-555-0113', 'https://tranquilspa.example.com');
GO

-- CancellationPolicy: 13 rows, one per location (LocationID 1-13).
-- Rows 1-10 keep each business's original rules. The new locations show
-- both sides of the per-location design:
--   11 (Luxe, Cambridge)      = same rules as location 1 (shared policy, duplicated row)
--   12 (Urban Cuts, downtown) = stricter than location 5 (busy weekday-commuter shop)
--   13 (Tranquil, Brookline)  = same rules as location 7
INSERT INTO dbo.CancellationPolicy (LocationID, NoticePeriod, FeeAmount, RefundRule) VALUES
(1,  24, 25.00, 'Full refund if cancelled 24+ hours in advance; otherwise 50% fee applies'),
(2,  12, 10.00, 'Full refund if cancelled 12+ hours in advance; otherwise flat fee applies'),
(3,  48, 50.00, 'Full refund if cancelled 48+ hours in advance; otherwise no refund'),
(4,  24, 15.00, 'Full refund if cancelled 24+ hours in advance; otherwise flat fee applies'),
(5,  6,  5.00,  'Full refund if cancelled 6+ hours in advance; otherwise flat fee applies'),
(6,  24, 20.00, 'Full refund if cancelled 24+ hours in advance; otherwise 50% fee applies'),
(7,  48, 40.00, 'Full refund if cancelled 48+ hours in advance; otherwise no refund'),
(8,  24, 15.00, 'Full refund if cancelled 24+ hours in advance; otherwise flat fee applies'),
(9,  12, 10.00, 'Full refund if cancelled 12+ hours in advance; otherwise flat fee applies'),
(10, 24, 10.00, 'Full refund if cancelled 24+ hours in advance; otherwise flat fee applies'),
(11, 24, 25.00, 'Full refund if cancelled 24+ hours in advance; otherwise 50% fee applies'),
(12, 12, 15.00, 'Full refund if cancelled 12+ hours in advance; otherwise flat fee applies'),
(13, 48, 40.00, 'Full refund if cancelled 48+ hours in advance; otherwise no refund');
GO

-- LocationSocialMedia: 15 rows. 1-10 are one per location (LocationID 1-10).
-- 11-15 add a second platform for some locations and accounts for two of
-- the new locations. (LocationID, Platform) is UNIQUE, so no location
-- lists the same platform twice.
INSERT INTO dbo.LocationSocialMedia (LocationID, Platform, URL) VALUES
(1,  'Instagram', 'https://instagram.com/luxehairstudio'),
(2,  'Instagram', 'https://instagram.com/bloomnailbar'),
(3,  'Facebook',  'https://facebook.com/serenitymedspa'),
(4,  'Instagram', 'https://instagram.com/pawfectgrooming'),
(5,  'Instagram', 'https://instagram.com/urbancutsbarbershop'),
(6,  'TikTok',    'https://tiktok.com/@glowbeautylounge'),
(7,  'Facebook',  'https://facebook.com/tranquilspawellness'),
(8,  'Instagram', 'https://instagram.com/chichairco'),
(9,  'Instagram', 'https://instagram.com/polishednailsandco'),
(10, 'Facebook',  'https://facebook.com/furandfeatherpetspa'),
(1,  'TikTok',    'https://tiktok.com/@luxehairstudio'),
(4,  'Facebook',  'https://facebook.com/pawfectgrooming'),
(6,  'Instagram', 'https://instagram.com/glowbeautylounge'),
(11, 'Instagram', 'https://instagram.com/luxehairstudio.cambridge'),
(12, 'Instagram', 'https://instagram.com/urbancuts.downtown');
GO

-- ServiceCategory: 12 rows. 1-10 are one per business (BusinessID 1-10).
-- 11-12 give two businesses a second category:
--   11 = Color Services   (Business 1, Luxe Hair Studio)
--   12 = Laser Treatments (Business 3, Serenity Medspa)
INSERT INTO dbo.ServiceCategory (BusinessID, Name, Description) VALUES
(1,  'Hair Services', 'Haircuts, blowouts, and styling'),
(2,  'Nail Services', 'Manicures, pedicures, and nail art'),
(3,  'Medspa Treatments', 'Skincare and non-surgical wellness treatments'),
(4,  'Pet Grooming', 'Bathing, trimming, and grooming for pets'),
(5,  'Barbering', 'Men''s haircuts, beard trims, and shaves'),
(6,  'Beauty Treatments', 'Facials, waxing, and lash services'),
(7,  'Spa & Wellness', 'Massage and body treatments'),
(8,  'Hair Styling', 'Cuts, extensions, and blowouts'),
(9,  'Nail Art', 'Gel services and custom nail art'),
(10, 'Pet Spa Services', 'Grooming and bathing for pets'),
(1,  'Color Services', 'Single-process color, highlights, and toning'),
(3,  'Laser Treatments', 'Laser hair removal and skin resurfacing');
GO

-- Service: 22 rows. 1-10 are one per category (ServiceCategoryID 1-10).
-- 11-22 add more services to several categories. 
INSERT INTO dbo.Service (ServiceCategoryID, Name, Description, EstimatedDuration, Price) VALUES
(1,  'Women''s Haircut', 'Shampoo, cut, and style', 60, 65.00),
(2,  'Classic Manicure', 'Nail shaping, cuticle care, and polish', 30, 25.00),
(3,  'Signature Facial', 'Deep-cleansing facial with custom treatment', 60, 120.00),
(4,  'Full-Service Dog Grooming', 'Bath, haircut, nail trim, and ear cleaning', 90, 70.00),
(5,  'Men''s Haircut & Beard Trim', 'Haircut with beard shaping', 45, 40.00),
(6,  'Eyebrow Waxing', 'Precision eyebrow shaping with wax', 15, 20.00),
(7,  'Swedish Massage', 'Full-body relaxation massage', 60, 95.00),
(8,  'Hair Extensions Application', 'Full set of tape-in extensions', 120, 250.00),
(9,  'Nail Art Design', 'Custom nail art on gel manicure', 45, 45.00),
(10, 'Cat Grooming', 'Bath, brush-out, and nail trim for cats', 45, 55.00),
(1,  'Blowout', 'Wash and blow-dry styling', 45, 45.00),
(1,  'Deep Conditioning Treatment', 'Moisture treatment (add-on)', 15, 20.00),
(11, 'Single-Process Color', 'All-over root-to-tip color', 90, 110.00),
(11, 'Full Highlights', 'Foil highlights throughout', 150, 180.00),
(2,  'Gel Pedicure', 'Pedicure with long-lasting gel polish', 60, 50.00),
(2,  'Paraffin Hand Treatment', 'Warm paraffin wax hand treatment (add-on)', 15, 15.00),
(4,  'Teeth Brushing', 'Dental brushing for dogs (add-on)', 10, 10.00),
(5,  'Hot Towel Shave', 'Traditional straight-razor shave', 30, 35.00),
(7,  'Hot Stone Massage', 'Full-body massage with heated stones', 90, 140.00),
(7,  'Aromatherapy Upgrade', 'Essential oil blend added to massage (add-on)', 15, 15.00),
(12, 'Laser Hair Removal - Small Area', 'Laser hair removal for a small treatment area', 30, 150.00),
(3,  'LED Light Therapy', 'LED skin treatment (add-on)', 20, 40.00);
GO