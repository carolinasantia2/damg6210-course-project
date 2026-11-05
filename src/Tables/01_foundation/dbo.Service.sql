-- Service: a bookable service within a category (1 ServiceCategory : many Services).
-- Must be created AFTER dbo.ServiceCategory.
CREATE TABLE dbo.Service (
    ServiceID          INT IDENTITY(1,1) NOT NULL,
    ServiceCategoryID  INT               NOT NULL,
    Name               VARCHAR(100)      NOT NULL,
    Description        VARCHAR(500)      NULL,
    EstimatedDuration  INT               NOT NULL,  -- minutes
    Price              DECIMAL(10,2)     NOT NULL,

    CONSTRAINT PK_Service PRIMARY KEY (ServiceID),
    CONSTRAINT FK_Service_ServiceCategory
        FOREIGN KEY (ServiceCategoryID) REFERENCES dbo.ServiceCategory (ServiceCategoryID),
    CONSTRAINT CK_Service_EstimatedDuration CHECK (EstimatedDuration > 0),
    CONSTRAINT CK_Service_Price             CHECK (Price >= 0)
);
GO