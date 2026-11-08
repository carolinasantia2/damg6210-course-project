CREATE TABLE dbo.Payment (
    PaymentID INT IDENTITY(1,1) NOT NULL,
    AppointmentID INT NOT NULL,
    PaymentMethodID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    ChargedAt DATETIME NOT NULL,
    Type VARCHAR(30) NOT NULL,
    CONSTRAINT PK_Payment PRIMARY KEY (PaymentID),
    CONSTRAINT FK_Payment_Appointment FOREIGN KEY (AppointmentID)
        REFERENCES dbo.Appointment (AppointmentID),
    CONSTRAINT FK_Payment_PaymentMethod FOREIGN KEY (PaymentMethodID)
        REFERENCES dbo.PaymentMethod (PaymentMethodID),
    CONSTRAINT CK_Payment_Amount CHECK (Amount >= 0),
    CONSTRAINT CK_Payment_Type CHECK (Type IN ('Deposit', 'Full Payment')),
    CONSTRAINT CK_Payment_Status CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Refunded'))
);
GO
