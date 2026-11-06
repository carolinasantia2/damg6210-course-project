CREATE TABLE dbo.Appointment (
    AppointmentID INT IDENTITY(1,1) NOT NULL,
    CustomerID    INT               NOT NULL,
    BookedAt      DATETIME2(0)      NOT NULL
        CONSTRAINT DF_Appointment_BookedAt DEFAULT (SYSDATETIME()),
 
    CONSTRAINT PK_Appointment PRIMARY KEY (AppointmentID),
    CONSTRAINT FK_Appointment_Customer
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
 
    -- CHECK #7: sanity floor on booking timestamps
    CONSTRAINT CK_Appointment_BookedAt
        CHECK (BookedAt >= '2020-01-01')
);
GO
   
CREATE UNIQUE INDEX UX_Customer_Email
    ON dbo.Customer (Email) WHERE Email IS NOT NULL;
GO
 