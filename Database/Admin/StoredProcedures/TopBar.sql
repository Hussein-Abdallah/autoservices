USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTopBar_Upsert
-- EXEC AutoServicesSchema.spTopBar_Upsert @TopBarId = 1, @Announcement = '24/7 Service provided', @CtaActive = 1, @ButtonLabel = 'Book Appointment', @ButtonLink = 'booking';
    @TopBarId INT = NULL,
    @Announcement NVARCHAR(100),
    @CtaActive BIT,
    @ButtonLabel NVARCHAR(50),
    @ButtonLink NVARCHAR(100),
    @IsActive BIT = 0
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @TopBarId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.TopBar
                        SET Announcement = @Announcement,
                            CtaActive = @CtaActive,
                            ButtonLabel = @ButtonLabel,
                            ButtonLink = @ButtonLink,
                            IsActive = @IsActive
                        WHERE TopBarId = @TopBarId;
                END
            ELSE
                BEGIN
                    DECLARE @numberOfRows INT;
                    SELECT @numberOfRows = COUNT(*) FROM AutoServicesSchema.TopBar;

                    IF @numberOfRows = 0
                        BEGIN
                            INSERT INTO AutoServicesSchema.TopBar (Announcement, CtaActive, ButtonLabel, ButtonLink, IsActive)
                            VALUES (@Announcement, @CtaActive, @ButtonLabel, @ButtonLink, @IsActive); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Top bar section already exist. You can only create 1 top bar section',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTopBar_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating the Top Bar section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTopBar_GetInfo
-- EXEC AutoServicesSchema.spTopBar_GetInfo
AS
BEGIN
    BEGIN TRY
        SELECT TopBarId, Announcement, CtaActive, ButtonLabel, ButtonLink, IsActive
        FROM AutoServicesSchema.TopBar;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTopBar_GetInfo', GETDATE());

        THROW 50003, 'An error occurred while retrieving Top Bar section information. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTopBar_Delete
-- EXEC AutoServicesSchema.spTopBar_Delete
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.TopBar;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTopBar_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting Top Bar data. Please try again or contact support.', 1;
    END CATCH;
END;
GO
