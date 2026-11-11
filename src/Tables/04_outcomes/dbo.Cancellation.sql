CREATE TABLE dbo.Cancellation (
    CancellationID INT IDENTITY(1,1) NOT NULL,
    AppointmentID  INT NOT NULL,
    CancelledAt    DATETIME NOT NULL,
    CancelledBy    VARCHAR(50) NOT NULL,
    Reason         VARCHAR(255) NULL,
    FeeCharged     DECIMAL(10,2) NOT NULL,
    RefundAmount   DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Cancellation PRIMARY KEY (CancellationID),
    CONSTRAINT FK_Cancellation_Appointment FOREIGN KEY (AppointmentID)
        REFERENCES dbo.Appointment (AppointmentID),
    CONSTRAINT UQ_Cancellation_AppointmentID UNIQUE (AppointmentID),
    CONSTRAINT CK_Cancellation_FeeCharged CHECK (FeeCharged >= 0),
    CONSTRAINT CK_Cancellation_RefundAmount CHECK (RefundAmount >= 0)
);
GO
