-- CancellationPolicy: one policy per Location (1:1, enforced by the UNIQUE
-- constraint on LocationID). Changed from the P3 design, where the policy
-- belonged to Business, so each location of a multi-location business can
-- set its own rules. Must be created AFTER dbo.Location.
CREATE TABLE dbo.CancellationPolicy (
    CancellationPolicyID  INT IDENTITY(1,1) NOT NULL,
    LocationID            INT               NOT NULL,
    NoticePeriod          INT               NOT NULL,  -- hours of notice required
    FeeAmount             DECIMAL(10,2)     NOT NULL,
    RefundRule            VARCHAR(255)      NULL,

    CONSTRAINT PK_CancellationPolicy PRIMARY KEY (CancellationPolicyID),
    CONSTRAINT UQ_CancellationPolicy_LocationID UNIQUE (LocationID),
    CONSTRAINT FK_CancellationPolicy_Location
        FOREIGN KEY (LocationID) REFERENCES dbo.Location (LocationID),
    CONSTRAINT CK_CancellationPolicy_NoticePeriod CHECK (NoticePeriod >= 0),
    CONSTRAINT CK_CancellationPolicy_FeeAmount    CHECK (FeeAmount >= 0)
);
GO