-- AppointmentService: one service booked within an appointment, i.e. the
-- line items of an Appointment (1 Appointment : many AppointmentServices).
-- Each row carries its own service, staff member, time slot, and status,
-- so one appointment can mix services with different staff, slots, and
-- outcomes. ParentAppointmentServiceID is a nullable self-reference: NULL
-- for a core service, or the core service row that an add-on belongs to.
-- Rules that compare rows or tables (the staff member owns the slot, the
-- add-on is in the same appointment as its parent, etc.) can't be CHECKs,
-- so they're verified in tests/05_appointment_service_data_rows.sql.
-- Must be created AFTER dbo.Appointment, dbo.Service, dbo.Staff, and
-- dbo.TimeSlot.
CREATE TABLE dbo.AppointmentService (
    AppointmentServiceID        INT IDENTITY(1,1) NOT NULL,
    AppointmentID               INT               NOT NULL,
    ServiceID                   INT               NOT NULL,
    ParentAppointmentServiceID  INT               NULL,
    TimeSlotID                  INT               NOT NULL,
    StaffID                     INT               NOT NULL,
    Status                      VARCHAR(20)       NOT NULL,

    CONSTRAINT PK_AppointmentService PRIMARY KEY (AppointmentServiceID),
    CONSTRAINT FK_AppointmentService_Appointment
        FOREIGN KEY (AppointmentID) REFERENCES dbo.Appointment (AppointmentID),
    CONSTRAINT FK_AppointmentService_Service
        FOREIGN KEY (ServiceID) REFERENCES dbo.Service (ServiceID),
    -- Self-reference: an add-on points to its core service row.
    CONSTRAINT FK_AppointmentService_ParentAppointmentService
        FOREIGN KEY (ParentAppointmentServiceID) REFERENCES dbo.AppointmentService (AppointmentServiceID),
    CONSTRAINT FK_AppointmentService_TimeSlot
        FOREIGN KEY (TimeSlotID) REFERENCES dbo.TimeSlot (TimeSlotID),
    CONSTRAINT FK_AppointmentService_Staff
        FOREIGN KEY (StaffID) REFERENCES dbo.Staff (StaffID),

    CONSTRAINT CK_AppointmentService_Status
        CHECK (Status IN ('Confirmed', 'Waitlisted', 'Cancelled', 'Completed')),
    -- A row can't be an add-on to itself. NULL (a core service) passes.
    CONSTRAINT CK_AppointmentService_ParentAppointmentServiceID
        CHECK (ParentAppointmentServiceID <> AppointmentServiceID)
);
GO

-- A time slot can be held by only one active booking. A filtered index is
-- used instead of a UNIQUE constraint so that cancelled and waitlisted rows
-- don't block the slot: a cancelled slot can be rebooked, and a waitlisted
-- customer is by definition waiting on a slot someone else holds.
CREATE UNIQUE INDEX UQ_AppointmentService_TimeSlotID
    ON dbo.AppointmentService (TimeSlotID)
    WHERE Status IN ('Confirmed', 'Completed');
GO