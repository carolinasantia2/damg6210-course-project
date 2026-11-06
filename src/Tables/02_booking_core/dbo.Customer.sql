DROP TABLE IF EXISTS dbo.Appointment;
DROP TABLE IF EXISTS dbo.PaymentMethod;
DROP TABLE IF EXISTS dbo.Customer;
GO

CREATE TABLE dbo.Customer (
    CustomerID               INT IDENTITY(1,1) NOT NULL,
    FirstName                VARCHAR(50)       NOT NULL,
    LastName                 VARCHAR(50)       NOT NULL,
    PhoneNumber              VARCHAR(20)       NULL,
    Email                    VARCHAR(255)      NULL,
    CustomerPreferredContact VARCHAR(20)       NOT NULL
        CONSTRAINT DF_Customer_PreferredContact DEFAULT ('Email'),
    RegistrationDate DATE NOT NULL
        CONSTRAINT DF_Customer_RegistrationDate DEFAULT(GETDATE()),
    CONSTRAINT PK_Customer PRIMARY KEY (CustomerID),

    --CHECK 1.a customer must be reachable by at least one channel 
    CONSTRAINT CK_Customer_HasContact 
        CHECK (Email is not null or PhoneNumber is not null),
    --CHECK 2.prefereed contact must be a supported channel and actually be on file 
    CONSTRAINT CK_Customer_PreferredContact 
        CHECK (
                (CustomerPreferredContact = 'Email' AND Email is not null) 
             OR  (CustomerPreferredContact IN ('Phone','SMS') AND PhoneNumber is not null)
),
    --CHECK 3.Email (xyz@xyz.xyz)
    CONSTRAINT CK_Customer_EmailFormat
        CHECK (Email is null or Email LIKE '%_@_%._%')
);
GO