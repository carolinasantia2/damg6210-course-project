CREATE TABLE dbo.PaymentMethod (
    PaymentMethodID INT IDENTITY(1,1) NOT NULL,
    CustomerID      INT               NOT NULL,
    CardType        VARCHAR(20)       NOT NULL,
    LastFourDigits  CHAR(4)           NOT NULL,
    ExpirationDate  DATE              NOT NULL,
 
    CONSTRAINT PK_PaymentMethod PRIMARY KEY (PaymentMethodID),
    CONSTRAINT FK_PaymentMethod_Customer
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
 
    -- Only digits, exactly four of them
    CONSTRAINT CK_PaymentMethod_LastFourDigits 
        CHECK (LastFourDigits LIKE '[0-9][0-9][0-9][0-9]'),
 
    -- Supported card brands
    CONSTRAINT CK_PaymentMethod_CardType
        CHECK (CardType IN ('Visa','Mastercard','Amex','Discover')),
 
    -- Cards expire at month end (MM/YY), so the stored date must
    --           be the last day of its month. Deliberately NOT "in the
    --           future" – that would make old rows invalid over time.
    CONSTRAINT CK_PaymentMethod_ExpirationDate 
        CHECK (ExpirationDate = EOMONTH(ExpirationDate))
);
GO