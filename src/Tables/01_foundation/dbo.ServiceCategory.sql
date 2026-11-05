-- ServiceCategory: groups a Business's services (1 Business : many categories).
CREATE TABLE dbo.ServiceCategory (
    ServiceCategoryID  INT IDENTITY(1,1) NOT NULL,
    BusinessID         INT               NOT NULL,
    Name               VARCHAR(100)      NOT NULL,
    Description        VARCHAR(500)      NULL,

    CONSTRAINT PK_ServiceCategory PRIMARY KEY (ServiceCategoryID),
    CONSTRAINT FK_ServiceCategory_Business
        FOREIGN KEY (BusinessID) REFERENCES dbo.Business (BusinessID)
);
GO