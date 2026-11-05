-- Business: the top-level tenant. Everything in the foundation cluster
-- hangs off this table directly or through Location / ServiceCategory.
CREATE TABLE dbo.Business (
    BusinessID   INT IDENTITY(1,1) NOT NULL,
    Name         VARCHAR(150)      NOT NULL,
    Description  VARCHAR(500)      NULL,

    CONSTRAINT PK_Business PRIMARY KEY (BusinessID)
);
GO