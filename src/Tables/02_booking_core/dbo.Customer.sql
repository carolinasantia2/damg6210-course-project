-- Customer: a person who books appointments. Customers aren't tied to a
-- business, so one customer can book at any location.
-- Phone and email are each optional, but at least one is required, and
-- the preferred contact method must be one that's on file.
-- Must be created BEFORE dbo.Appointment and dbo.PaymentMethod.
CREATE TABLE dbo.Customer (
    CustomerID                INT IDENTITY(1,1) NOT NULL,
    FirstName                 VARCHAR(50)       NOT NULL,
    LastName                  VARCHAR(50)       NOT NULL,
    PhoneNumber               VARCHAR(20)       NULL,
    Email                     VARCHAR(255)      NULL,
    CustomerPreferredContact  VARCHAR(20)       NOT NULL,
    RegistrationDate          DATE              NOT NULL
        CONSTRAINT DF_Customer_RegistrationDate DEFAULT (GETDATE()),

    CONSTRAINT PK_Customer PRIMARY KEY (CustomerID),
    -- A customer must be reachable by at least one channel.
    CONSTRAINT CK_Customer_HasContact
        CHECK (Email IS NOT NULL OR PhoneNumber IS NOT NULL),
    -- The preferred contact must be a supported channel that's on file.
    CONSTRAINT CK_Customer_PreferredContact
        CHECK (   (CustomerPreferredContact = 'Email' AND Email IS NOT NULL)
               OR (CustomerPreferredContact IN ('Phone', 'SMS') AND PhoneNumber IS NOT NULL)),
    -- Basic email shape (xyz@xyz.xyz), same rule as Staff.Email.
    CONSTRAINT CK_Customer_Email
        CHECK (Email IS NULL OR Email LIKE '%_@_%._%')
);
GO

-- Email must be unique when present. A filtered index is used instead of a
-- UNIQUE constraint because UNIQUE in SQL Server allows only one NULL.
CREATE UNIQUE INDEX UQ_Customer_Email
    ON dbo.Customer (Email)
    WHERE Email IS NOT NULL;
GO