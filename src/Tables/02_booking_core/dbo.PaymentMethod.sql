-- PaymentMethod: a card a customer has stored on file (1 Customer : many
-- PaymentMethods). Storing a card is optional, so a customer can have
-- none. Only the last four digits are kept, never the full card number.
-- Must be created AFTER dbo.Customer.
CREATE TABLE dbo.PaymentMethod (
    PaymentMethodID  INT IDENTITY(1,1) NOT NULL,
    CustomerID       INT               NOT NULL,
    CardType         VARCHAR(20)       NOT NULL,
    LastFourDigits   CHAR(4)           NOT NULL,
    ExpirationDate   DATE              NOT NULL,

    CONSTRAINT PK_PaymentMethod PRIMARY KEY (PaymentMethodID),
    CONSTRAINT FK_PaymentMethod_Customer
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer (CustomerID),
    -- Exactly four digits.
    CONSTRAINT CK_PaymentMethod_LastFourDigits
        CHECK (LastFourDigits LIKE '[0-9][0-9][0-9][0-9]'),
    -- Supported card brands.
    CONSTRAINT CK_PaymentMethod_CardType
        CHECK (CardType IN ('Visa', 'Mastercard', 'Amex', 'Discover')),
    -- Cards expire at the end of a month (MM/YY), so the stored date must
    -- be the last day of its month. Deliberately not "in the future",
    -- since that would make old rows invalid over time.
    CONSTRAINT CK_PaymentMethod_ExpirationDate
        CHECK (ExpirationDate = EOMONTH(ExpirationDate))
);
GO