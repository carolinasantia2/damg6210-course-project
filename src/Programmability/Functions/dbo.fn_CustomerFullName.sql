-- fn_CustomerFullName: a customer's display name.
-- Returns FirstName + ' ' + LastName for the given customer, or NULL if no
-- customer has that ID. VARCHAR(101) = 50 (FirstName) + 1 (space) + 50 (LastName).
-- Used by: the reporting views (P5-05).
--
-- Example:
--   SELECT dbo.fn_CustomerFullName(6);  -- Liam O'Brien
CREATE OR ALTER FUNCTION dbo.fn_CustomerFullName (@CustomerID INT)
RETURNS VARCHAR(101)
AS
BEGIN
    DECLARE @FullName VARCHAR(101);

    SELECT @FullName = FirstName + ' ' + LastName
    FROM dbo.Customer
    WHERE CustomerID = @CustomerID;

    RETURN @FullName;
END;
GO
