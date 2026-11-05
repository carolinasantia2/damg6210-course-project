-- Location: a physical site operated by a Business (1 Business : many Locations).
CREATE TABLE dbo.Location (
    LocationID      INT IDENTITY(1,1) NOT NULL,
    BusinessID      INT               NOT NULL,
    Street          VARCHAR(150)      NOT NULL,
    City            VARCHAR(100)      NOT NULL,
    State           VARCHAR(50)       NOT NULL,
    Zip             VARCHAR(10)       NOT NULL,
    OperatingHours  VARCHAR(255)      NULL,
    ContactPhone    VARCHAR(20)       NOT NULL,
    Website         VARCHAR(255)      NULL,

    CONSTRAINT PK_Location PRIMARY KEY (LocationID),
    CONSTRAINT FK_Location_Business
        FOREIGN KEY (BusinessID) REFERENCES dbo.Business (BusinessID)
);
GO