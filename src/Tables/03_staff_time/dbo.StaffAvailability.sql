-- StaffAvailability: a broad window a staff member has declared open for
-- booking, e.g. 2025-10-20 09:00-17:00 (1 Staff : many StaffAvailability).
-- Bookable TimeSlots are carved out of these windows.
-- Must be created AFTER dbo.Staff.
CREATE TABLE dbo.StaffAvailability (
    StaffAvailabilityID  INT IDENTITY(1,1) NOT NULL,
    StaffID              INT               NOT NULL,
    AvailabilityDate     DATE              NOT NULL,
    StartTime            TIME              NOT NULL,
    EndTime              TIME              NOT NULL,

    CONSTRAINT PK_StaffAvailability PRIMARY KEY (StaffAvailabilityID),
    CONSTRAINT FK_StaffAvailability_Staff
        FOREIGN KEY (StaffID) REFERENCES dbo.Staff (StaffID),
    -- The same window can't be declared twice for one staff member.
    CONSTRAINT UQ_StaffAvailability_StaffID_Date_StartTime
        UNIQUE (StaffID, AvailabilityDate, StartTime),
    CONSTRAINT CK_StaffAvailability_EndTime CHECK (StartTime < EndTime)
);
GO
