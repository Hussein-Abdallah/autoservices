USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spHeroSection_Upsert
-- EXEC AutoServicesSchema.spHeroSection_Upsert @SectionId
    @HeroSectionId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @Title NVARCHAR(100) = NULL,
    @Subtitle NVARCHAR(200) = NULL,
    @CtaActive BIT = 0,
    @ButtonLabel NVARCHAR(50) = NULL,
    @ButtonLink NVARCHAR(100) = NULL,
    @ImageUrl NVARCHAR(100) = NULL,
    @TextAlignment NVARCHAR(5) = 'left'
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @HeroSectionId IS NULL
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

            INSERT INTO AutoServicesSchema.HeroSection (ContainerId, Title, Subtitle, CtaActive, ButtonLabel, ButtonLink, ImageUrl, TextAlignment)
            VALUES (@sc_ContainerId, @Title, @Subtitle, @CtaActive, @ButtonLabel, @ButtonLink, @ImageUrl, @TextAlignment);
        END
        ELSE
        BEGIN
            UPDATE AutoServicesSchema.HeroSection
            SET Title = @Title,
                Subtitle = @Subtitle,
                CtaActive = @CtaActive,
                ButtonLabel = @ButtonLabel,
                ButtonLink = @ButtonLink,
                ImageUrl = @ImageUrl,
                TextAlignment = @TextAlignment
            WHERE HeroSectionId = @HeroSectionId;
        END;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spHeroSection_Upsert', GETDATE());

        THROW 50003, 'An error occurred while creating/updating the Hero Section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spHeroSection_Delete
-- EXEC AutoServicesSchema.spHeroSection_Delete
@HeroSectionId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get the OrderSequence of the banner being deleted
        DECLARE @DeletedOrderSequence INT;
        DECLARE @ContainerId INT;

        SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
            @ContainerId = HeroSection.ContainerId
            FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                JOIN AutoServicesSchema.HeroSection AS HeroSection
                    ON SectionsConfig.ContainerId = HeroSection.ContainerId
            WHERE HeroSection.HeroSectionId = @HeroSectionId;

        -- Delete the banner from Banner table
        DELETE FROM AutoServicesSchema.HeroSection
        WHERE HeroSectionId = @HeroSectionId;

        -- Delete the record from SectionsConfig
        EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

        -- Adjust the sequence order for remaining banners
        EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spHeroSection_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting the banner. Please try again or contact support.', 1;
    END CATCH;
END;
GO