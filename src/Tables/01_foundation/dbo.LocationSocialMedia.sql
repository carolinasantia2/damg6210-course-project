-- LocationSocialMedia: social accounts for a Location (1 Location : many accounts).
-- The UNIQUE constraint stops the same platform being listed twice for one location.
CREATE TABLE dbo.LocationSocialMedia (
    LocationSocialMediaID  INT IDENTITY(1,1) NOT NULL,
    LocationID             INT               NOT NULL,
    Platform               VARCHAR(50)       NOT NULL,
    URL                    VARCHAR(255)      NOT NULL,

    CONSTRAINT PK_LocationSocialMedia PRIMARY KEY (LocationSocialMediaID),
    CONSTRAINT UQ_LocationSocialMedia_Location_Platform UNIQUE (LocationID, Platform),
    CONSTRAINT FK_LocationSocialMedia_Location
        FOREIGN KEY (LocationID) REFERENCES dbo.Location (LocationID)
);
GO