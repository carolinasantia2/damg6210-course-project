-- ---------- Drop all tables (reverse dependency order) ----------
-- Children are dropped before parents so no FK blocks a drop. Covers ALL
-- 17 tables, not just the foundation cluster: dropping dbo.Location while
-- a teammate's dbo.Staff still references it would fail. DROP TABLE IF
-- EXISTS (SQL Server 2016+) skips tables that haven't been created yet,
-- so this runs cleanly at any stage of the project.
-- Run against your project database (no USE statement here; the database
-- name is set once at the top of dist/create_database_and_schema.sql).

-- 05 AppointmentService (FKs to 02, 01, 03, and itself)
DROP TABLE IF EXISTS dbo.AppointmentService;

-- 04 Outcomes
DROP TABLE IF EXISTS dbo.Notification;
DROP TABLE IF EXISTS dbo.Cancellation;
DROP TABLE IF EXISTS dbo.Payment;

-- 03 Staff & time
DROP TABLE IF EXISTS dbo.TimeSlot;
DROP TABLE IF EXISTS dbo.StaffAvailability;
DROP TABLE IF EXISTS dbo.StaffService;
DROP TABLE IF EXISTS dbo.Staff;

-- 02 Booking core
DROP TABLE IF EXISTS dbo.PaymentMethod;
DROP TABLE IF EXISTS dbo.Appointment;
DROP TABLE IF EXISTS dbo.Customer;

-- 01 Foundation
DROP TABLE IF EXISTS dbo.Service;
DROP TABLE IF EXISTS dbo.ServiceCategory;
DROP TABLE IF EXISTS dbo.LocationSocialMedia;
DROP TABLE IF EXISTS dbo.CancellationPolicy;
DROP TABLE IF EXISTS dbo.Location;
DROP TABLE IF EXISTS dbo.Business;
GO
