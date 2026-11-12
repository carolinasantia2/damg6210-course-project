-- Appointment: one booking made by a customer (1 Customer : many
-- Appointments). The appointment itself only records who booked and when.
-- The services, staff, time slots, and statuses live on its
-- AppointmentService rows, so one appointment can include several services.
-- Must be created AFTER dbo.Customer.
CREATE TABLE dbo.Appointment (
    AppointmentID  INT IDENTITY(1,1) NOT NULL,
    CustomerID     INT               NOT NULL,
    BookedAt       DATETIME          NOT NULL
        CONSTRAINT DF_Appointment_BookedAt DEFAULT (GETDATE()),

    CONSTRAINT PK_Appointment PRIMARY KEY (AppointmentID),
    CONSTRAINT FK_Appointment_Customer
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
    -- Sanity floor on booking timestamps. "Not in the future" is checked
    -- in tests/02_booking_core_data_rows.sql instead, since a CHECK
    -- against the current time is brittle.
    CONSTRAINT CK_Appointment_BookedAt
        CHECK (BookedAt >= '2020-01-01')
);
GO