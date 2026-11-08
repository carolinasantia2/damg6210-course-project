CREATE TABLE dbo.Notification (
    NotificationID INT IDENTITY(1,1) NOT NULL,
    CustomerID INT NOT NULL,
    AppointmentID INT NOT NULL,
    Type VARCHAR(30) NOT NULL,
    SentAt DATETIME NOT NULL,
    DeliveryMethod VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Notification PRIMARY KEY (NotificationID),
    CONSTRAINT FK_Notification_Customer FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customer (CustomerID),
    CONSTRAINT FK_Notification_Appointment FOREIGN KEY (AppointmentID)
        REFERENCES dbo.Appointment (AppointmentID),
    CONSTRAINT CK_Notification_Type CHECK (Type IN ('Confirmation', 'Reminder', 'Cancellation')),
    CONSTRAINT CK_Notification_DeliveryMethod CHECK (DeliveryMethod IN ('Email', 'SMS', 'Phone'))
);
GO
