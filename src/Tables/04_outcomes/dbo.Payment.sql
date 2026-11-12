-- Payment: one charge against an appointment, either a Deposit at booking
-- or a Full Payment at the visit (1 Appointment : many Payments).
-- PaymentMethodID is nullable because a stored card is optional
-- (M:0-1 PaymentMethod), e.g. a cash payment at the counter. When present,
-- the card must belong to the appointment's customer, which is verified in
-- tests/04_outcomes_data_rows.sql.
-- Must be created AFTER dbo.Appointment and dbo.PaymentMethod.
CREATE TABLE dbo.Payment (
    PaymentID       INT IDENTITY(1,1) NOT NULL,
    AppointmentID   INT NOT NULL,
    PaymentMethodID INT NULL,
    Amount          DECIMAL(10,2) NOT NULL,
    Status          VARCHAR(20) NOT NULL,
    ChargedAt       DATETIME NOT NULL,
    Type            VARCHAR(30) NOT NULL,

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
