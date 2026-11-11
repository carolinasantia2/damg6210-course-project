-- TimeSlot: a discrete, service-length bookable chunk carved out of one
-- StaffAvailability window (1 StaffAvailability : many TimeSlots).
-- Referenced by AppointmentService.TimeSlotID.
-- A slot should fall inside its window (same date, between its start and
-- end times). A CHECK can't look at another table, so that rule is
-- verified in tests/03_staff_time_data_rows.sql instead.
-- Must be created AFTER dbo.StaffAvailability.
CREATE TABLE dbo.TimeSlot (
    TimeSlotID           INT IDENTITY(1,1) NOT NULL,
    StaffAvailabilityID  INT               NOT NULL,
    Date                 DATE              NOT NULL,
    StartTime            TIME              NOT NULL,
    EndTime              TIME              NOT NULL,

    CONSTRAINT PK_TimeSlot PRIMARY KEY (TimeSlotID),
    CONSTRAINT FK_TimeSlot_StaffAvailability
        FOREIGN KEY (StaffAvailabilityID) REFERENCES dbo.StaffAvailability (StaffAvailabilityID),
    CONSTRAINT CK_TimeSlot_EndTime CHECK (StartTime < EndTime)
);
GO
