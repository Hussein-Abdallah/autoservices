USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spServiceSection_Upsert
    -- EXEC AutoServicesSchema.spServiceSection_Upsert
    @ServiceSectionId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @Title NVARCHAR(100) = NULL,
    @Subtitle NVARCHAR(200) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @ServiceSectionId IS NULL
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

                    INSERT INTO AutoServicesSchema.ServiceSection (ContainerId, Title, Subtitle)
                    VALUES (@sc_ContainerId, @Title, @Subtitle);
                END
                ELSE
                BEGIN
                    UPDATE AutoServicesSchema.ServiceSection
                    SET Title = @Title,
                        Subtitle = @Subtitle
                    WHERE ServiceSectionId = @ServiceSectionId;
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

CREATE OR ALTER PROCEDURE AutoServicesSchema.spServiceSection_Delete
-- EXEC AutoServicesSchema.spServiceSection_Delete
@ServiceSectionId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @DeletedOrderSequence INT;
            DECLARE @ContainerId INT;

            SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
                @ContainerId = ServiceSection.ContainerId
                FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                    JOIN AutoServicesSchema.ServiceSection AS ServiceSection
                        ON SectionsConfig.ContainerId = ServiceSection.ContainerId
                WHERE ServiceSection.ServiceSectionId = @ServiceSectionId;

            DELETE FROM AutoServicesSchema.ServiceSection
                WHERE ServiceSectionId = @ServiceSectionId;

            Delete FROM AutoServicesSchema.ServiceCard
                WHERE ServiceSectionId = @ServiceSectionId;

            EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

            EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spServiceSection_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting the Service Section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spServiceCard_Upsert
-- EXEC AutoServicesSchema.spServiceCard_Upsert
    @CardId INT = NULL,
    @ServiceSectionId INT = NULL,
    @IconId INT = NULL,
    @Price DECIMAL(6,2) = NULL,
    @Title NVARCHAR(50) = NULL,
    @Summary NVARCHAR(150) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @CardId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.ServiceCard
                        SET IconId = @IconId,
                            Title = @Title,
                            Price = @Price,
                            Summary = @Summary
                        WHERE CardId = @CardId 
                            AND ServiceSectionId = @ServiceSectionId;
                END
            ELSE
                BEGIN
                    IF @ServiceSectionId IS NOT NULL
                        BEGIN
                            INSERT INTO AutoServicesSchema.ServiceCard (ServiceSectionId, IconId, Price, Title, Summary)
                                VALUES (@ServiceSectionId, @IconId, @Price, @Title, @Summary); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Service section doesn''t exist. Create a Service section before adding a Service Card',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spServiceCard_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating a Service Card. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spServiceCard_GetAll
-- EXEC AutoServicesSchema.spServiceCard_GetAll
@ServiceSectionId INT
AS
BEGIN
    BEGIN TRY
        SELECT CardId, IconId, Price, Title, Summary
            FROM AutoServicesSchema.ServiceCard
            WHERE ServiceSectionId = @ServiceSectionId;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spServiceCard_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving the service card. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spServiceCard_Delete
-- EXEC AutoServicesSchema.spServiceCard_Delete
@CardId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.ServiceCard
                WHERE CardId = @CardId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spServiceCard_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting a service card. Please try again or contact support.', 1;
    END CATCH;
END;
GO