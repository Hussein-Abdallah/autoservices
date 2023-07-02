CREATE OR ALTER PROCEDURE AutoServicesSchema.spNewsletter_GetInfo
-- EXEC AutoServicesSchema.spNewsletter_GetInfo
AS
BEGIN
    BEGIN TRY
        SELECT Email
        FROM AutoServicesSchema.Newsletter;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spNewsletter_GetInfo', GETDATE());

        THROW 50003, 'An error occurred while retrieving newsletter email list. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spNewsletter_Add
    -- EXEC AutoServicesSchema.spNewsletter_Add
    @Email NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @EmailExist INT;
        SELECT @EmailExist = COUNT(*) FROM AutoServicesSchema.Newsletter
        WHERE Email = @Email;

        IF @EmailExist = 0
        BEGIN
            INSERT INTO AutoServicesSchema.Newsletter(Email)
            VALUES(@Email);
        END
        ELSE
        BEGIN;
            THROW 50002, 'Email already exists in our newsletter database.', 1;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spNewsletter_Add', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spNewsletter_Unsubscribe
    -- EXEC AutoServicesSchema.spNewsletter_Unsubscribe
    @Email NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @EmailExist INT;
        SELECT @EmailExist = COUNT(*) FROM AutoServicesSchema.Newsletter
        WHERE Email = @Email;

        IF @EmailExist = 1
        BEGIN
            DELETE FROM AutoServicesSchema.Newsletter
                WHERE Email = @Email;
        END
        ELSE
        BEGIN;
            THROW 50002, 'Email doesn''t exist in our newsletter database.', 1;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spNewsletter_Unsubscribe', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO