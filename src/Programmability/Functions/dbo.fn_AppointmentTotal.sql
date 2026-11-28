-- fn_AppointmentTotal: the total price of one appointment.
-- Returns the sum of Service.Price across every AppointmentService row of
-- the appointment, core services and add-ons both. Returns 0.00 (not NULL)
-- when the appointment has no services or doesn't exist.
-- The total isn't stored on Appointment (see design doc 3.4): it's derived
-- from the line items, so this function is the one place it's computed.
-- Used by: the reporting views (P5-05) and dbo.usp_CompleteAppointment (P5-08).
--
-- Example:
--   SELECT dbo.fn_AppointmentTotal(4);  -- 160.00 (facial + LED add-on)
CREATE OR ALTER FUNCTION dbo.fn_AppointmentTotal (@AppointmentID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);

    SELECT @Total = SUM(s.Price)
    FROM dbo.AppointmentService aps
    JOIN dbo.Service s ON s.ServiceID = aps.ServiceID
    WHERE aps.AppointmentID = @AppointmentID;

    RETURN ISNULL(@Total, 0);
END;
GO
