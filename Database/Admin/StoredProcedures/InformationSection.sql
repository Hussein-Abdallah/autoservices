USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spInformationSection_Upsert
    -- EXEC AutoServicesSchema.spInformationSection_Upsert
    @InformationSectionId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @IsAccordionActive BIT = 0,
    @IsBlogActive BIT = 0
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @InformationSectionId IS NULL
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

                    INSERT INTO AutoServicesSchema.InformationSection (ContainerId, IsAccordionActive, IsBlogActive)
                    VALUES (@sc_ContainerId, @IsAccordionActive, @IsBlogActive);
                END
                ELSE
                BEGIN
                    UPDATE AutoServicesSchema.InformationSection
                    SET IsAccordionActive = @IsAccordionActive,
                        IsBlogActive = @IsBlogActive
                    WHERE InformationSectionId = @InformationSectionId;
                END
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spInformationSection_Upsert', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spInformationSection_Delete
-- EXEC AutoServicesSchema.spInformationSection_Delete
@InformationSectionId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @DeletedOrderSequence INT;
            DECLARE @ContainerId INT;

            SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
                @ContainerId = InformationSection.ContainerId
                FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                    JOIN AutoServicesSchema.InformationSection AS InformationSection
                        ON SectionsConfig.ContainerId = InformationSection.ContainerId
                WHERE InformationSection.InformationSectionId = @InformationSectionId;

            DELETE FROM AutoServicesSchema.InformationSection
                WHERE InformationSectionId = @InformationSectionId;

            EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

            EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spInformationSection_Delete', GETDATE());

        THROW 50004, @ErrorMessage, 1;
    END CATCH;
END;
GO