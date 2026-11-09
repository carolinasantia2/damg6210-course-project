-- StaffService: associative entity resolving Staff <-> Service (M:N).
-- One row = one staff member can perform one service, at a given proficiency.
-- Must be created AFTER dbo.Staff and dbo.Service.
CREATE TABLE dbo.StaffService (
    StaffServiceID    INT IDENTITY(1,1) NOT NULL,
    StaffID           INT               NOT NULL,
    ServiceID         INT               NOT NULL,
    ProficiencyLevel  VARCHAR(30)       NOT NULL,

    CONSTRAINT PK_StaffService PRIMARY KEY (StaffServiceID),
    CONSTRAINT FK_StaffService_Staff
        FOREIGN KEY (StaffID) REFERENCES dbo.Staff (StaffID),
    CONSTRAINT FK_StaffService_Service
        FOREIGN KEY (ServiceID) REFERENCES dbo.Service (ServiceID),
    -- A staff/service pairing is recorded once (one proficiency per pairing).
    CONSTRAINT UQ_StaffService_StaffID_ServiceID UNIQUE (StaffID, ServiceID),
    CONSTRAINT CK_StaffService_ProficiencyLevel
        CHECK (ProficiencyLevel IN ('Beginner', 'Intermediate', 'Expert'))
);
GO
