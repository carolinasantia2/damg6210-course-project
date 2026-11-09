CREATE TABLE dbo.Appointment (
    AppointmentID INT IDENTITY(1,1) NOT NULL,
    CustomerID    INT               NOT NULL,
    BookedAt      DATETIME      NOT NULL
        CONSTRAINT DF_Appointment_BookedAt DEFAULT (GETDATE()),
 
    CONSTRAINT PK_Appointment PRIMARY KEY (AppointmentID),
    CONSTRAINT FK_Appointment_Customer
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
 
    -- CHECK #7: sanity floor on booking timestamps
    CONSTRAINT CK_Appointment_BookedAt
        CHECK (BookedAt >= '2020-01-01')
);
GO
   
 