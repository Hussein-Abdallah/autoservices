USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spHeader_Upsert
-- EXEC AutoServicesSchema.spHeader_Upsert
@HeaderId INT = NULL,
@LogoImage NVARCHAR(100) = NULL,
@LogoTitle NVARCHAR(100) = NULL,
@IsNavigationActive BIT = 1
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @HeaderId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.Header
                        SET LogoImage = @LogoImage,
                            LogoTitle = @LogoTitle,
                            IsNavigationActive = @IsNavigationActive
                        WHERE HeaderId = @HeaderId;
                END
            ELSE
                BEGIN
                    DECLARE @numberOfRows INT;
                    SELECT @numberOfRows = COUNT(*) FROM AutoServicesSchema.Header;

                    IF @numberOfRows = 0
                        BEGIN
                            INSERT INTO AutoServicesSchema.Header (LogoImage, LogoTitle, IsNavigationActive)
                            VALUES (@LogoImage, @LogoTitle, @IsNavigationActive); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Header section already exist. You can only create 1 Header section',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spHeader_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating the Header section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spHeader_GetInfo
-- EXEC AutoServicesSchema.spHeader_GetInfo
AS
BEGIN
    BEGIN TRY
        SELECT LogoImage, LogoTitle, IsNavigationActive
        FROM AutoServicesSchema.Header;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spHeader_GetInfo', GETDATE());

        THROW 50003, 'An error occurred while retrieving Top Bar section information. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spHeader_Delete
-- EXEC AutoServicesSchema.spHeader_Delete
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.Header;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spHeader_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting Header data. Please try again or contact support.', 1;
    END CATCH;
END;
GO