USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spMobileApp_Upsert
    -- EXEC AutoServicesSchema.spMobileApp_Upsert
    @MobileAppId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @Title NVARCHAR(100) = NULL,
    @Subtitle NVARCHAR(200) = Null,
    @AppDescription NVARCHAR(500) = NULL,
    @AndroidUrl NVARCHAR(200) = NULL,
    @AppleUrl NVARCHAR(200) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @MobileAppId IS NULL
                BEGIN
                    DECLARE @sc_ErrorMessage NVARCHAR(200);
                    DECLARE @sc_ContainerId INT;

                    EXEC AutoServicesSchema.spSectionsConfig_InsertSection
                        @sc_SectionId = @SectionId,
                        @sc_IsActive = @IsActive,
                        @sc_ContainerId = @sc_ContainerId OUTPUT,
                        @sc_ErrorMessage = @sc_ErrorMessage OUTPUT;

                    IF @sc_ErrorMessage IS NOT NULL
                    BEGIN
                        ROLLBACK;
                        THROW 50002, @sc_ErrorMessage, 1;
                    END;

                    INSERT INTO AutoServicesSchema.MobileApp (ContainerId, Title, Subtitle, AppDescription, AndroidUrl, AppleUrl)
                    VALUES (@sc_ContainerId, @Title, @Subtitle, @AppDescription, @AndroidUrl, @AppleUrl);
                END
                ELSE
                BEGIN
                    UPDATE AutoServicesSchema.MobileApp
                    SET Title = @Title,
                        Subtitle = @Subtitle,
                        AppDescription = @AppDescription,
                        AndroidUrl = @AndroidUrl,
                        AppleUrl = @AppleUrl
                    WHERE MobileAppId = @MobileAppId;
                END
        COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spMobileApp_Upsert', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spMobileApp_Delete
-- EXEC AutoServicesSchema.spMobileApp_Delete
@MobileAppId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @DeletedOrderSequence INT;
            DECLARE @ContainerId INT;

            SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
                @ContainerId = MobileApp.ContainerId
                FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                    JOIN AutoServicesSchema.MobileApp AS MobileApp
                        ON SectionsConfig.ContainerId = MobileApp.ContainerId
                WHERE MobileApp.MobileAppId = @MobileAppId;

            DELETE FROM AutoServicesSchema.MobileApp
                WHERE MobileAppId = @MobileAppId;

            Delete FROM AutoServicesSchema.CounterCard
                WHERE MobileAppId = @MobileAppId;

            EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

            EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spMobileApp_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting the Mobile App Section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spCounterCard_Upsert
-- EXEC AutoServicesSchema.spCounterCard_Upsert
    @CounterCardId INT = NULL,
    @MobileAppId INT = NULL,
    @IconId INT,
    @Total INT,
    @Title NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @CounterCardId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.CounterCard
                        SET IconId = @IconId,
                            Title = @Title,
                            Total = @Total
                        WHERE CounterCardId = @CounterCardId 
                            AND MobileAppId = @MobileAppId;
                END
            ELSE
                BEGIN
                    IF @MobileAppId IS NOT NULL
                        BEGIN
                            INSERT INTO AutoServicesSchema.CounterCard (MobileAppId, IconId, Title, Total)
                                VALUES (@MobileAppId, @IconId, @Title, @Total); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Mobile App section doesn''t exist. Create a Mobile App section before adding a Counter Card',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spCounterCard_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating a Service Card. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spCounterCard_GetAll
-- EXEC AutoServicesSchema.spCounterCard_GetAll
@MobileAppId INT
AS
BEGIN
    BEGIN TRY
        SELECT CounterCard.CounterCardId, CounterCard.MobileAppId, Icons.IconName, CounterCard.Total, CounterCard.Title
            FROM AutoServicesSchema.CounterCard AS CounterCard
                JOIN AutoServicesSchema.Icons AS Icons
                    ON CounterCard.IconId = Icons.IconId
            WHERE CounterCard.MobileAppId = @MobileAppId;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spCounterCard_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving all counter card. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spCounterCard_Delete
-- EXEC AutoServicesSchema.spCounterCard_Delete
@CounterCardId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.CounterCard
                WHERE CounterCardId = @CounterCardId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spCounterCard_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting a counter card. Please try again or contact support.', 1;
    END CATCH;
END;
GO