USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spIcons_Upsert
    -- EXEC AutoServicesSchema.spIcons_Upsert
    @IconId INT = NULL,
    @IconName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @IconId IS NULL
                BEGIN
                    INSERT INTO AutoServicesSchema.Icons (IconName)
                    VALUES (@IconName);
                END
                ELSE
                BEGIN
                    UPDATE AutoServicesSchema.Icons
                    SET IconName = @IconName
                    WHERE IconId = @IconId;
                END
        COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spServiceSection_Upsert', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spIcons_GetAll
-- EXEC AutoServicesSchema.spIcon_GetAll
AS
BEGIN
    BEGIN TRY
        SELECT *
            FROM AutoServicesSchema.Icons;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spIcon_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving Icons. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spIcons_GetIconName
-- EXEC AutoServicesSchema.spIcon_GetAll
@IconId INT
AS
BEGIN
    BEGIN TRY
        SELECT IconName
            FROM AutoServicesSchema.Icons
            WHERE IconId = @IconId;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spIcon_GetIconName', GETDATE());

        THROW 50003, 'An error occurred while retrieving Icon name. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spIcons_Delete
-- EXEC AutoServicesSchema.spIcons_Delete
@IconId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DELETE FROM AutoServicesSchema.Icons
                WHERE IconId = @IconId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spIcons_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting an Icon. Please try again or contact support.', 1;
    END CATCH;
END;
GO