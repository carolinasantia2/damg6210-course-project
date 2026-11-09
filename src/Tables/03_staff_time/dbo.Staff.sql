-- Staff: an employee who performs services at one Location
-- (1 Location : many Staff). Must be created AFTER dbo.Location.
CREATE TABLE dbo.Staff (
    StaffID      INT IDENTITY(1,1) NOT NULL,
    LocationID   INT               NOT NULL,
    FirstName    VARCHAR(50)       NOT NULL,
    LastName     VARCHAR(50)       NOT NULL,
    Role         VARCHAR(30)       NOT NULL,
    Email        VARCHAR(255)      NOT NULL,
    PhoneNumber  VARCHAR(20)       NULL,

    CONSTRAINT PK_Staff PRIMARY KEY (StaffID),
    CONSTRAINT FK_Staff_Location
        FOREIGN KEY (LocationID) REFERENCES dbo.Location (LocationID),
    -- Each staff member has their own work email.
    CONSTRAINT UQ_Staff_Email UNIQUE (Email),
    -- Basic email shape (xyz@xyz.xyz), same rule as Customer.Email.
    CONSTRAINT CK_Staff_Email CHECK (Email LIKE '%_@_%._%')
);
GO
